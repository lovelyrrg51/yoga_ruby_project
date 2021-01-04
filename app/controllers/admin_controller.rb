class AdminController < ApplicationController
  include AdminHelper

  MAX_MERGE_PROFILES_ALLOWED = 5
  MERGABLE_MODELS = [:event_registration, :sy_club_member, :sy_club_sadhak_profile_association]

  before_action :authenticate_user!
  before_action :locate_collection, only: [:search_sadhak]

  def registration_invoices

    authorize :admin

    @event_registrations = EventRegistration.filter(filtering_params).page(params[:page]).per(params[:per_page]).order('event_registrations.id DESC').includes(:sadhak_profile, :event, {event_order: [:attachment]})

  end

  def photo_approval_admin_panel

    authorize(:admin, :photo_approval_admin_panel?)

    @photo_approval_panel_heading = 'Photo Approval Admin Panel'

    @sadhak_profiles = SadhakProfile.joins("left join event_registrations on event_registrations.sadhak_profile_id = sadhak_profiles.id").where("event_registrations.sadhak_profile_id is null").filter(params.slice(:syid, :first_name, :email, :mobile, :photo_approval_status)).order(:id).includes({advance_profile: [:advance_profile_photograph, :advance_profile_identity_proof]}).page(params[:page]).per(params[:per_page])

  end

  def export_photo_approval_list
    begin

      authorize(:admin, :export_photo_approval_list?)

      report_master = ReportMaster.find_by_id(params[:report_master_id])
      raise 'Please select a valid report type.' unless report_master.present?

      # Verify download list type
      raise "List type cannot be blank." unless params[:type].present?
      raise "Please provide a valid list type" unless %w(xls csv).include?(params[:type])

      # Verify required params
      report_master.required_params.each do |rp|
        raise "#{rp.titleize} cannot be blank." unless params.has_key?(rp) or params[rp].present?
      end

      recipients = (params[:recipients].try(:split, ',').try(:extract_valid_emails).try(:uniq) || [])

      sync = (not recipients.present?)

      if sync
        begin
          results = Timeout.timeout(5) do
            SadhakProfile.joins("left join event_registrations on event_registrations.sadhak_profile_id = sadhak_profiles.id").where("event_registrations.sadhak_profile_id is null").order(:id)
          end
        rescue Timeout::Error
          raise 'We are not able to process your request for such large data. Please use email option.'
        end

        raise 'We are not able to process your request for such large data. Please use email option.' if results.size > 1000

        raise 'No sadhak profile(s) found, Try searching with some other criteria.' unless results.present?
      end

      t_config = {file_name: "#{report_master.report_name}_report", prefix: "#{ENV['ENVIRONMENT']}/reports/#{report_master.report_name}", template: 'search_sadhak_result', sync: sync}

      task = Task.new(taskable_id: current_user.try(:id), taskable_type: 'User', email: recipients.join(','), opts: params, t_config: t_config, start_block: report_master.start_block, final_block: report_master.final_block)

      raise task.errors.full_messages.first unless task.save

      task.add_start_block do |parent_task, params = {}|
        raise ArgumentError.new('Parent task cannot be blank.') unless parent_task.present?

        # Get sadhak Profiles
        sadhak_profiles = SadhakProfile.joins('left join event_registrations on event_registrations.sadhak_profile_id = sadhak_profiles.id').where('event_registrations.sadhak_profile_id is null').order(:id)

        if params[:report_master_field_association_ids].present?
          report_field_ass = ReportMasterFieldAssociation.where(id: params[:report_master_field_association_ids])
        else
          report_field_ass = ReportMasterFieldAssociation.where(report_master_id: params[:report_master_id])
        end

        params[:batch_size] = (3e6 / (report_field_ass.size * 16)).to_i

        parent_task.result = sadhak_profiles.pluck(:id)
      end

      if sync
        blob = task.create_subtasks
      else
        task.delay.create_subtasks
      end

    rescue Exception => e
      is_error = true
      message = e.message
    end

    unless is_error
      if recipients.present?
        flash[:notice] = "Soon you will get an email on #{recipients.to_sentence}."
        redirect_back(fallback_location: proc { photo_approval_admin_panel_admin_index_path })
      else
        send_data blob, :filename => "#{t_config[:file_name]}_#{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}.#{params[:type]}"
      end
    else
      flash[:alert] = message
      redirect_back(fallback_location: proc { photo_approval_admin_panel_admin_index_path })
    end
  end

  def merge_syid

    authorize :admin

    @merge_sadhaks = MergeSadhak.includes({user: [:sadhak_profile]}).page(params[:page]).per(params[:per_page]).order('id DESC')

  end

  def match_merge_syid

    authorize :admin

    begin

      primary_sadhak_profile = SadhakProfile.find_by_id(match_merge_syid_params[:primary_sadhak].to_s.strip[/-?\d+/])

      raise 'Primary sadhak profile not found.' unless primary_sadhak_profile.present?

      secondary_sadhak_profile_ids = match_merge_syid_params[:secondary_sadhak].to_s.split(',').collect{|syid| syid.to_s.strip[/-?\d+/].to_i } - [nil, ""]

      secondary_sadhak_profiles = SadhakProfile.where(id: secondary_sadhak_profile_ids)

      raise 'Please input valid merging sadhak profile(s).' unless secondary_sadhak_profiles.present?

      raise "cannot merge #{secondary_sadhak_profiles.size} profile(s) at once. Maximum #{MAX_MERGE_PROFILES_ALLOWED} allowed at once." if secondary_sadhak_profiles.size > MAX_MERGE_PROFILES_ALLOWED

      not_found_secondary_sadhak_profile_syids = (secondary_sadhak_profile_ids - secondary_sadhak_profiles.pluck(:id)).collect{|id| "SY#{id}"}.join(' ,')

      raise "Merging profile(s) with syid: #{not_found_secondary_sadhak_profile_syids} not found. Please use valid sadhak profile(s) for merging." if not_found_secondary_sadhak_profile_syids.present?

      raise "Primary and merging syid cannot be the same. Please remove #{primary_sadhak_profile.syid} from merging sadhak list." if secondary_sadhak_profiles.include?(primary_sadhak_profile)

      secondary_sadhak_profiles = secondary_sadhak_profiles.sort_by{|x| secondary_sadhak_profile_ids.index(x.id)}

      uniq_secondary_sp_first_names = secondary_sadhak_profiles.collect{|sp| sp.first_name.to_s.downcase}.uniq

      is_first_name_match = primary_sadhak_profile.first_name.downcase == uniq_secondary_sp_first_names.first && uniq_secondary_sp_first_names.size == 1

      if is_first_name_match || match_merge_syid_params[:force].present?

        is_mergable_entities_found = false

        merge_ref_number = loop do
          ref_number = Utilities::UniqueKeyGenerator.generate
          break ref_number unless MergeSadhak.exists?(merge_ref_number: ref_number)
        end

        admin = Admin.build

        ApplicationRecord.transaction do

          secondary_sadhak_profiles.each do |secondary_sadhak_profile|

            merge_meta_data = {}

            MERGABLE_MODELS.each do |model|

              model = model.to_s

              result = admin.try("merge_#{model.pluralize}".to_sym, primary_sadhak_profile, secondary_sadhak_profile, merge_ref_number) || []

              merge_meta_data["#{model}_ids".to_sym] = result

              is_mergable_entities_found ||= result.present?

            end

            merge_sadhak = MergeSadhak.new(primary_sadhak_id: primary_sadhak_profile.id,  secondary_sadhak_id: secondary_sadhak_profile.id, user_id: current_user.id, meta_data: merge_meta_data, merge_ref_number: merge_ref_number)

            merge_sadhak.save!

          end

          raise 'Nothing found mergable.' unless is_mergable_entities_found

        end

        @success = "#{secondary_sadhak_profiles.size} profile(s) merged successfully with merge reference number: #{merge_ref_number}."

      else

        respond_to do |format|
          format.js
        end

      end

    rescue Exception => e
      @message = e.message
    end

    (@message.present? || @success.present?) && respond_to do |format|
      format.js { render 'ajax' }
    end

  end

  def users_associated_with_provider

    authorize :admin
    @authoriztions = Authorization.page(params[:page]).per(params[:per_page])

  end

  def change_users_associated_with_provider

    authorize :admin
    user_id = params[:authorization][:user_id]

    begin

      Authorization.find_by_id(params[:authorization][:id]).update!(user_id: user_id)
      flash[:success] = 'User is successfully Updated.'

    rescue Exception => e

      flash[:alert] = e.message

    end

      redirect_to users_associated_with_provider_admin_index_path

  end

  def search_sadhak
    authorize :admin
    @states = DbState.country_id(params[:country_id])
    @cities = DbCity.state_id(params[:state_id])
    @filtering_params = filtering_params
  end

  def locate_collection
    @qsadhak_profiles = SadhakProfilePolicy::Scope.new(current_user, SadhakProfile.preloaded_data).resolve(filtering_params).distinct.page(params[:page]).per(params[:per_page])
  end

  def authorizations

    begin

      @authorizations = filtering_params.present? ? AuthorizationPolicy::Scope.new(current_user, Authorization).resolve(filtering_params).page(params[:page]).per(params[:per_page]).order('authorizations.id DESC').includes({ user: [:sadhak_profile] }) : Authorization.page(params[:page]).per(params[:per_page]).order('authorizations.id DESC').includes({user: [:sadhak_profile] })

    rescue Exception => e

      message = e.message

    end

    redirect_back(fallback_location: proc { authorizations_admin_index_path }) if message.present?

  end

  def update_authorization

    begin

      raise "Authorization not Found." unless params[:auth_id].present?
      raise "No User Found." unless params[:user_id].present?

      @authorization = Authorization.find_by_id(params[:auth_id])
      @authorization.update!(user_id: params[:user_id])

    rescue Exception => e

      @message = e.message

    end

    respond_to do |format|
      format.js
    end

  end

  def deleted_sadhak_profiles
  	authorize :admin
		@sadhak_profiles = SadhakProfile.only_deleted.order("deleted_at DESC").page(params[:page]).per(params[:per_page])
  end

  def restore_sadhak_profile
  	authorize :admin
  	SadhakProfile.restore(params[:id], :recursive => true, :recovery_window => 2.minutes)
		if SadhakProfile.find(params[:id])
			flash[:success] = "Sadhak profile has been successfully restored."
		else
			flash[:error] = "Error occured while restoring sadhak."
		end

		redirect_back(fallback_location: root_path)
  end

  def sadhaks_episodes
    authorize :admin
    begin
      if params[:syid].present?
        @sadhak_profile = SadhakProfile.syid(params[:syid]).last
        raise SyException, "No Sadhak Profile Found." unless @sadhak_profile.present?
        @accessible_collections = @sadhak_profile.user.collections_for_chrome_extension
        @downloaded_episodes = DigitalAsset.where(id: @sadhak_profile.extension_detail.try(:downloaded_assets)).includes(:collection)
      end
    rescue SyException => e
      error = e.message
    end
    flash[:error] = error if error.present?
  end


  private
  def filtering_params
    params.slice(:reg_ref_number, :transaction_id, :invoice_number, :reg_invoice_from, :reg_invoice_to, :payment_method, :reg_invoice_event, :first_name, :last_name, :syid, :provider_name, :email, :mobile, :status, :occupation, :profession_id, :country_id, :state_id, :city_id, :registration_center_id, :registration_from, :registration_to, :creation_from, :creation_to)
  end

  def match_merge_syid_params
    params.require(:admin).permit(:primary_sadhak, :secondary_sadhak, :force)
  end

end
