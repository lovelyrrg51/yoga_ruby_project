class SyClubsController < ApplicationController

	NON_STORABLE_ACTIONS = %w(nearest_sy_clubs autocomplete datatables)
	
  before_action :authenticate_user!, except: [:nearest_sy_clubs, :index, :sadhak_non_members, :datatables, :show, :register, :sy_club_register_forgot_syid, :sy_club_register_syid_search, :autocomplete, :verify_members, :process_club_members, :payment, :complete, :transfer_complete]
  before_action :set_sy_club, only: [:show, :members, :update, :register, :sy_club_register_syid_search, :sy_club_register_forgot_syid, :verify_members, :process_club_members, :transfer_complete]
  before_action :render_404_if_disabled_forum, only: [:register, :show]
  before_action :set_event_order, only: [:payment, :complete]
  before_action :locate_collection, only: [:index, :nearest_sy_clubs]
  before_action :get_forums_and_sadhaks, only: [:sadhak_non_members]
  skip_before_action :verify_authenticity_token, :only => [:update]

  #GET /index
  def index
  end

  def datatables
		render json: SyClubsDatatable.new(view_context)
  end

  def sadhak_profile_datatables
    render json: SadhakProfile.non_banned_sadhaks.last(10).to_json
  end

  # GET /forums/id
  def show
  end

  #GET /forums/new
  def new

    @sy_club = SyClub.new

    authorize @sy_club
    address = @sy_club.build_address
    address.build_db_country
    address.build_db_state
    address.build_db_city

    SyClubUserRole.limit(2).find_each do |role|
      @sy_club.sy_club_sadhak_profile_associations.build(sy_club_user_role_id: role.id)
    end
    
  end

  #POST /forums/create
  def create

    begin
      @sy_club = SyClub.new(sy_club_params)
      @sy_club.content_type = params.dig(:sy_club, :content_type).try(:reject, &:empty?).try(:join, ",")
      authorize @sy_club
      if @sy_club.save
        flash[:success] = 'Forum is Successfully Created.'
      else
        raise SyException, @sy_club.errors.full_messages.first
      end
    rescue SyException => e
      message = e.message
    end

    if message.present?
      flash[:error] = message.to_s
      render :new
    else
      redirect_to @sy_club
    end
    
  end

  # PUT/PATCH /forum/id
  def update
    authorize @sy_club
    begin
      raise "Please select a valid statues." unless SyClub.statuses[sy_club_params[:status]] if sy_club_params[:status]
      @sy_club.update!(sy_club_params)
    rescue Exception => e
      message = e.message
    end

    message.present? ? flash[:alert] = message : flash[:success] = "Forum has been successfully updated."
    redirect_back(fallback_location: proc { members_sy_club_path(@sy_club) })

  end 

  # GET /forums/id/admin/members
  def members
    authorize @sy_club
    begin
      @filtering_params = filtering_params
      @sy_club_members = filtering_params.present? ? SyClubMemberPolicy::Scope.new(current_user, @sy_club.sy_club_members).resolve(filtering_params).order(:id).page(params[:page]).per(params[:per_page]) : @sy_club.sy_club_members.approve.includes(:event_registration, :sadhak_profile).order(:id).page(params[:page]).per(params[:per_page])
    rescue Exception => e
      flash[:alert] = e.message
      redirect_back(fallback_location: proc { polymorphic_url(@sy_club) })
    end
  end

  #GET forums/verify_board_member
  def verify_board_member
    begin

      raise "No Index Found." unless @index = params[:index]
      raise "Please Enter the Syid for search." if params[:syid].blank?
      raise "Pease Enter the First Name for search." if params[:first_name].blank?

      syid = "sy#{params[:syid][/-?\d+/].to_i}".upcase
      first_name = params[:first_name].to_s.strip.downcase

      @sadhak_profile = SadhakProfile.where(syid: syid).first

      raise "No Sadhak Profile found with SYID #{syid}" unless @sadhak_profile.present?
      raise "Sadhak Profile found with SYID #{syid} doesn't match with name #{first_name}." unless @sadhak_profile.first_name.downcase.eql?(first_name)

     raise "#{@sadhak_profile.syid} is not allowed to be a Board Member of Forums." if @sadhak_profile.banned?

     raise "#{@sadhak_profile.syid} is not allowed to be a Board Member of Forums, as minimum age required is above #{SADHAK_MIN_AGE} years." if (@sadhak_profile.date_of_birth && @sadhak_profile.date_of_birth > (Date.today - SADHAK_MIN_AGE.year))

     raise "This Sadhak Profile is already a Member of another Forum." if SyClubSadhakProfileAssociation.joins(:sy_club).where.not(sy_clubs: { slug: params[:slug] }).where(sadhak_profile_id: @sadhak_profile.id).exists?

    rescue Exception => e
      @message = e.message
    end

    respond_to do |format|
      format.js
    end

  end

  #GET /forums/id/register
  def register
    begin

      raise "No valid CLP Event is attached to this Forum." unless @clp_event = @sy_club.clp_event

    rescue Exception => e
      flash[:alert] = e.message
      redirect_back(fallback_location: proc { sy_clubs_path })
    end
  end

  def sy_club_register_syid_search

    begin

      raise "No valid CLP Event is attached to this Forum." unless @clp_event = @sy_club.clp_event

      syid = "sy#{params[:sadhak_profiles][:syid][/-?\d+/].to_i}".upcase
      first_name = params[:sadhak_profiles][:first_name].to_s.strip.downcase
      mobile = params[:sadhak_profiles][:mobile].to_s.strip
      date_of_birth = Date.parse(params[:sadhak_profiles][:date_of_birth]) if params[:sadhak_profiles][:date_of_birth].present?
      raise "No Sadhak profile found." unless @sadhak_profile = SadhakProfile.where('syid = ? AND (LOWER(first_name) = ? OR mobile = ? OR date_of_birth = ?)', syid, first_name, mobile, date_of_birth).first

    rescue Exception => e

      logger.error("SadhakProfile: sy_club_register_syid_search: #{e.message}")
      @message= e.message

    end

    respond_to do |format|
      format.js { render 'sy_club_register_syid_search.js.erb' }
    end
  end

  def sy_club_register_forgot_syid

    begin

      raise "No valid CLP Event is attached to this Forum." unless @clp_event = @sy_club.clp_event
      
      sadhak_profiles = SadhakProfile.filter(params[:sadhak_profile].slice(:first_name, :last_name, :date_of_birth, :country_id, :state_id, :city_id).select!{ |k,v| v.present? })
      
      raise "No Sadhak profile found." unless sadhak_profiles.present?

      raise "Multiple Sadhak profiles found. Please do more precise search." if sadhak_profiles.count > 1

      @sadhak_profile = sadhak_profiles.last

    rescue Exception => e

      logger.error("SadhakProfile: sy_club_register_forgot_syid: #{e.message}")
      @message= e.message

    end

    respond_to do |format|
      format.js { render 'sy_club_register_syid_search.js.erb' }
    end
  end

  #POST /forums/id/verify_members
  def verify_members
    begin

      raise "No valid CLP Event is attached to this Forum." unless @clp_event = @sy_club.clp_event

      @details = @sy_club.check_transfer(forum_transfer_params.merge(event_id: @clp_event.id, sadhak_profiles: forum_transfer_params[:event_order_line_items_attributes].values).as_json.with_indifferent_access)

      @sadhak_profiles = SadhakProfile.where(id: forum_transfer_params[:event_order_line_items_attributes].values.pluck(:syid))

      @encrypted_params = forum_transfer_params.to_json.encrypt

    rescue Exception => e
      @message = e.message
    end

    respond_to do |format|
      format.js
    end
  end

  def process_club_members
    begin

      is_renewal_process = forum_transfer_params[:is_renewal_process].to_bool
      decrypted_forum_transfer_params = JSON.parse(forum_transfer_params[SY_CLUB_DETAILS.encrypt.to_sym].decrypt).with_indifferent_access

      raise "No valid CLP Event is attached to this Forum." unless @clp_event = @sy_club.clp_event

      @details = @sy_club.check_transfer(decrypted_forum_transfer_params.merge(event_id: @clp_event.id, sadhak_profiles: decrypted_forum_transfer_params[:event_order_line_items_attributes].values))

      raise "Some profile(s) are eligible for transfer/renew and some are new registration(s). cannot process together. Aborting." unless @details[:can_transfer] || @details[:can_renew] || @details[:fresh_registration]

      if @details[:fresh_registration] || (@details[:can_renew] && !@details[:can_transfer]) || (@details[:can_transfer] && @details[:can_renew] && is_renewal_process)

        is_renewal_process = true if (@details[:can_renew] && !@details[:can_transfer])

        #create event order
        @event_order = @clp_event.create_event_order(decrypted_forum_transfer_params.merge(current_user: current_user, event_id: @clp_event.id, sadhak_profiles:decrypted_forum_transfer_params[:event_order_line_items_attributes].values.each{|sp| sp[:sadhak_profile_id] = sp[:syid] }, sy_club_id: @sy_club.id, is_renewal_process: is_renewal_process))
        raise "New Event Order is not created." unless @event_order

        redirect_to payment_sy_club_path(@event_order)
        
      elsif @details[:can_transfer]

        @sy_club.do_transfer(@details)
        cookies[SY_CLUB_TRANSFER_DETAILS.encrypt.to_sym] = { value: SyClubMember.joins(:event_registration).where(event_registrations: { id: @details[:data].try(:pluck, :event_registration_id) }).ids.to_json.encrypt, expiry: Time.now + 5.minutes}
        redirect_to transfer_complete_sy_club_path(@sy_club)

      end

    rescue Exception => e
      flash[:alert] = e.message
      redirect_to register_sy_club_path(@sy_club)
    end
  end

	#GET forum/expired_forum_members
	def expired_forum_members
    @states = params[:country_id] && DbState.country_id(params[:country_id]) 
    @cities = params[:state_id] && DbCity.state_id(params[:state_id])

    @filtering_params = params.slice(:state_id, :country_id, :city_id, :syid, :expired_from, :expired_to).select{|k, v| v.present?}
    @sadhak_params = params.slice(:state_id, :country_id, :city_id, :syid).select{|k, v| v.present?}
    reg_params = params.slice(:expired_from, :expired_to).select{|k, v| v.present?}
    @sadhak_profiles = SadhakProfile.filter(@sadhak_params)
    @expired_regs = (reg_params.present? && EventRegistration.filter(reg_params) || EventRegistration).expired.joins(:sadhak_profile, :sy_club_member).includes(:sadhak_profile, :event_order, sy_club_member: [:sy_club]).merge(@sadhak_profiles).order('event_registrations.id DESC').page(params[:page]).per(params[:per_page])
	end

  # Downloads Expired Members as Excell
  def generate_expired_members_file
    begin

      sadhak_profile = SadhakProfile.last

      recipients = (params[:recipients].try(:split, ',').try(:extract_valid_emails).try(:uniq) || [])

      raise "Please provide valid emails." if params[:recipients].present? && !recipients.present?

      sync = (not recipients.present?)

      # # Authorize request
      raise SyException, 'You need to sign in or sign up before continuing.' unless SadhakProfilePolicy.new(current_user, sadhak_profile).generate_expired_members_file?

      raise SyException, 'SadhakProfile missing for logged in user' unless current_sadhak_profile.present?
      filtering_params = params.slice(:state_id, :country_id, :city_id, :syid, :expired_from, :expired_to).select{|k, v| v.present?}
      sadhak_params = params.slice(:state_id, :country_id, :city_id, :syid).select{|k, v| v.present?}

      reg_params = params.slice(:expired_from, :expired_to).select{|k, v| v.present?}

      sadhak_profiles = SadhakProfile.filter(sadhak_params)
      expired_regs = nil

      if sync
        begin
          search_results = Timeout.timeout(10) do
            expired_regs = (reg_params.present? && EventRegistration.filter(reg_params) || EventRegistration).expired.joins(:sadhak_profile, :sy_club_member).includes(:sadhak_profile, :event_order, sy_club_member: [:sy_club]).merge(sadhak_profiles).order('event_registrations.id DESC')
          end
        rescue Timeout::Error
          raise SyException, 'We are not able to process your request for such large data. Please use email option.'
        end

        raise SyException, 'We are not able to process your request for such large data. Please use email option.' if search_results.size > 1000

        raise SyException, 'No sadhak profile(s) found, Try searching with some other criteria.' unless search_results.present?
      end

      t_config = {file_name: 'expired_forum_members_search_result', prefix: "#{ENV['ENVIRONMENT']}/search_sy_club", template: 'expired_forum_members_list', sync: sync}

      task = Task.new(taskable_id: current_user.try(:id), taskable_type: 'User', email: recipients.join(','), opts: filtering_params, t_config: t_config)

      raise SyException, task.errors.full_messages.first unless task.save
      task.add_start_block do |parent_task, params = {}|

        raise ArgumentError.new('Parent task cannot be blank.') unless parent_task.present?

        sadhak_params = params.slice(:state_id, :country_id, :city_id, :syid).select{|k, v| v.present?}

        reg_params = params.slice(:expired_from, :expired_to).select{|k, v| v.present?}

        sadhak_profiles = SadhakProfile.filter(sadhak_params)

        search_results = (reg_params.present? && EventRegistration.filter(reg_params) || EventRegistration).expired.joins(:sadhak_profile, :sy_club_member).includes(:sadhak_profile, :event_order, sy_club_member: [:sy_club]).merge(sadhak_profiles).order('event_registrations.id DESC').uniq.pluck(:id)
        raise SyException, 'No members found, Try searching with some other criteria.' unless search_results.present?

        parent_task.result = search_results
      end


      task.add_final_block do |sub_task, expired_reg_ids, opts = {}|

        raise ArgumentError.new('Sub task cannot be blank.') unless sub_task.present?

        expired_regs = EventRegistration.where(id: expired_reg_ids).order(:id).includes(:sadhak_profile, :event_order, sy_club_member: [:sy_club])

        # Generate profiles data.
        data = expired_regs.last.generate_member_excel(expired_regs, opts[:status])

        file = sub_task.generate_excel_file(data.merge({data_type: opts[:sync] ? nil : 'file'}))

        sub_task.result = {file: file, from: expired_regs.first.id, to: expired_regs.last.id, format: 'xls'}
      end
      if sync
        blob = task.create_subtasks
      else
        task.delay.create_subtasks
      end
    rescue SyException => e
      is_error = true
      message = e.message
      logger.info("Manual Exception: #{message}")
    rescue Exception => e
      is_error = true
      message = e.message
      logger.info("Runtime Exception: #{message}")
    end

    unless is_error
      if recipients.present?
        flash[:success] = "Soon you will receive an email on #{recipients.to_sentence}."
        redirect_back(fallback_location: root_path)
      else
        send_data blob, :filename => "expired_forum_members_search_result#{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}.xls"
      end
    else
      flash[:error] =  message
      redirect_back(fallback_location: root_path)
    end
  end

  #GET forum/event_order_id/payment
  def payment
    begin
      raise "No Forum is attached to the Event Order." unless @sy_club = @event_order.sy_club

      raise "No Event is attached." unless @event = @event_order.event

      @currency = @event.currency_code
      
    rescue Exception => e
      flash[:alert] = e.message
      redirect_to register_sy_club_path(@sy_club)
    end
  end

  #GET forum/event_order_id/complete
  def complete
    begin

      raise "No Forum is attached to the Event Order." unless @sy_club = @event_order.sy_club

      raise "No Event is attached." unless @event = @event_order.event

    rescue Exception => e
      flash[:alert] = e.message
      redirect_to register_sy_club_path(@sy_club)
    end
  end

  def transfer_complete
    begin

      redirect_to polymorphic_url([@sy_club], action: :register) and return unless cookies[SY_CLUB_TRANSFER_DETAILS.encrypt.to_sym]

      sy_club_member_ids = JSON.parse(cookies[SY_CLUB_TRANSFER_DETAILS.encrypt.to_sym].decrypt)

      cookies.delete(SY_CLUB_TRANSFER_DETAILS.encrypt)

      @sy_club_member_action_details = SyClubMemberActionDetail.transfer.where(to_sy_club_member_id: sy_club_member_ids)

      @from_club = SyClubMember.unscoped.where(id: @sy_club_member_action_details.last.from_sy_club_member_id).last.try(:sy_club)
      @to_club = @sy_club_member_action_details.last.to_club

      @sy_club_members = SyClubMember.where(id: sy_club_member_ids)

    rescue Exception => e
      flash[:alert] = e.message
      redirect_to register_sy_club_path(@sy_club)
    end
  end

  # GET /nearest_sy_clubs 
  def nearest_sy_clubs
    respond_to do |format|
      format.js { @sy_clubs = @sy_clubs.includes(address:[:db_country, :db_state, :db_city]).limit(6) }
    end
  end

  def forum_admin
    authorize(:sy_club, :forum_admin?)
    @sy_clubs = (filtering_params.present? && SyClub.filter(filtering_params) || SyClub).order('id DESC').page(params[:page]).per(params[:per_page]).includes(sy_club_sadhak_profile_associations: [:sadhak_profile, :sy_club_user_role])
  end

  # GET /sy_clubs/autocomplete
  def autocomplete
    render json: Autocomplete::SyClubs.new(view_context)
  end

  def locate_collection
    @sy_clubs = SyClubPolicy::Scope.new(current_user, SyClub).resolve(filtering_params).order(:id).distinct.page(params[:page]).per(params[:per_page])
  end

  def offline_forum_data_migration
  	authorize(:sy_club)
  end

  def migrate_offline_forum_data
  	authorize(:sy_club, :offline_forum_data_migration?)

  	begin
  		raise "Please select a file." unless params[:forum_offline_data_file].present?
  		raise 'Please input recipients.' unless params[:recipients].present?
			recipients = params[:recipients].split(',').extract_valid_emails
			raise 'Please input valid recipients emails.' unless recipients.present?
	  	additional_details = params[:additiona_details]
	  	raise 'Please input additional details' unless additional_details.present?
	  	file_data = params[:forum_offline_data_file].tempfile

	  	# File size validation
	  	file_size_limit =  (MAX_ATTACHMENT_FILE_SIZE / 5) # 1048576 bytes
	  	file_size = file_data.size
	  	
	  	raise "File size cannot be more than 1 MB" if file_size >= file_size_limit

	  	# Upload file 
	  	xls_file_uploader = ExcelFileUploader.new
	  	xls_file_uploader.store!(file_data)

	  	file_url = xls_file_uploader.file.url

	  	SyClub.last.delay.forum_members_migration(file_url, additional_details, recipients)

  		flash[:success] = "File has been successfully upload, soon you will recieve mail."
  	rescue Exception => ex
  		flash[:error] = ex.message
  	end
  	redirect_back(fallback_location: root_path)
  end

  def sadhak_non_members
    authorize(:sy_club, :sadhak_non_members?)

    @forum = SyClub.find(params[:forum_id]) if params[:forum_id].present?
    country_id = @forum.present? ? @forum.address.country_id : params[:country_id]
    state_id = @forum.present? ? @forum.address.state_id : params[:state_id]
    city_id = @forum.present? ? @forum.address.city_id : params[:city_id]

    @non_members = @non_members.where(addresses: {country_id: country_id}) if country_id.present?
    @non_members = @non_members.where(addresses: {state_id: state_id}) if state_id.present?
    @non_members = @non_members.where(addresses: {city_id: city_id}) if city_id.present?

    @states = DbState.country_id(country_id) if country_id.present?
    @cities = DbCity.state_id(state_id) if state_id.present?

    @non_members = @non_members.page(params[:page]).per(params[:per_page]).includes(address: [:db_city, :db_state, :db_country])
  end

  private

  def filtering_params
    params.slice(:sy_club_id, :state_id, :country_id, :city_id, :lat, :lng, :sy_club_name, :status, :sadhak_syid, :sadhak_name).select{|k, v| v.present?}
  end

  def sy_club_params
    params.require(:sy_club).permit(:name, :min_members_count, :content_type, :status_notes, :members_count, :status,  :email, :contact_details, :event_ids,  :sadhak_profile_reference_ids, :event_type_ids, :other_activity, :cultural_activities, :sy_club_digital_arrangement_detail, :sadhak_profile_reference_ids => [], :event_ids => [], :event_type_ids => [],
    sy_club_sadhak_profile_associations_attributes: [:id, :sadhak_profile_id, :club_joining_date, :status, :sy_club_id, :sy_club_user_role_id],
    address_attributes: [:id, :first_line, :second_line, :country_id , :state_id, :other_state, :city_id, :other_city, :postal_code])
  end

  def set_sy_club
    if (params[:id].count("a-zA-Z") == 0)
      @sy_club = SyClub.find(params[:id])
      redirect_to url_for(params.permit!.except(:id).merge(id: @sy_club.slug)) if @sy_club.present?
    end
    @sy_club = SyClub.find(params[:id])
  end

  def forum_transfer_params
    params.require(:event_order).permit!
  end

  def render_404_if_disabled_forum
    raise ActiveRecord::RecordNotFound unless SyClubPolicy.new(current_user, :sy_club).show? if @sy_club.disabled?
  end

  def set_event_order
    @event_order = EventOrder.find_by!(slug: params[:id])
  end

  def get_forums_and_sadhaks
    @sy_clubs = SyClub.pluck(:name, :id)
    @non_members = SadhakProfile.all_non_member_sadhaks    
  end
end
