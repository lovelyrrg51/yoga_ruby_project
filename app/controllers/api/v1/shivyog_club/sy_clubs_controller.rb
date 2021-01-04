module Api::V1::ShivyogClub
  class SyClubsController < ::Api::V1::BaseController
    before_action :authenticate_user!, except: [:index, :create, :show, :join_club, :club_payment, :forum_register, :check_transfer, :forum_transfer, :content_types, :wp_sy_clubs, :wp_sy_club]
    before_action :set_sy_club, only: [:show, :edit, :update, :destroy, :wp_sy_club]
    before_action :locate_collection, :only => :index
    skip_before_action :verify_authenticity_token, :only => [:index, :create, :show, :join_club, :club_payment, :forum_register, :check_transfer, :forum_transfer, :content_types, :wp_sy_clubs, :wp_sy_club]
    respond_to :json

    # GET /sy_clubs
    def index
      render json: @sy_clubs, each_serializer: SyClubIndexSerializer, serializer: PaginationSerializer
    end

    # GET /wp_sy_clubs
    def wp_sy_clubs
      render json: SyClub.order(:id).all, each_serializer: WpSyClubIndexSerializer
    end

    # GET /wp_sy_club/1
    def wp_sy_club
      render json: @sy_club, serializer: WpSyClubSerializer
    end

    # GET /sy_clubs/1
    def show
      # render json: @sy_club
      sy_club_extra_fields = {
        active_members_count: @sy_club.try(:active_members_count),
        has_board_members_paid: @sy_club.try(:has_board_members_paid),
        address_id: @sy_club.try(:address).try(:id),
        sy_club_digital_arrangement_detail_id: @sy_club.try(:sy_club_digital_arrangement_detail).try(:id),
        sy_club_venue_detail_id: @sy_club.try(:sy_club_venue_detail).try(:id),
        event_ids: @sy_club.try(:event_ids),
        sadhak_profile_ids: @sy_club.try(:sadhak_profile_ids),
        event_type_ids: @sy_club.try(:event_type_ids),
        sy_club_sadhak_profile_association_ids: @sy_club.try(:sy_club_sadhak_profile_association_ids)
      }
      address = @sy_club.try(:address).as_json(:except => [:created_at, :updated_at, :district, :deleted_at, :address_type])
      address_extra_field = @sy_club.try(:address).try(:slice, :db_state_id, :db_city_id, :db_country_id)
      city_fields = @sy_club.try(:address).try(:db_city).try(:slice, :id, :state_id, :country_id, :name)
      state_fields = @sy_club.try(:address).try(:db_state).try(:slice, :id, :country_id, :name)
      country_fields = @sy_club.try(:address).try(:db_country).try(:slice, :id, :name, :telephone_prefix, :currency, :currency_code)

      render json: {
        addresses: [address.merge(address_extra_field)],
        db_cities: [city_fields],
        db_states: [state_fields],
        db_countries: [country_fields],
        sy_club_sadhak_profile_associations: get_sadhak_profile_associations,
        sy_club: @sy_club.as_json(:except => [:created_at, :updated_at, :user_id, :old_forum_id, :old_venue_id, :is_deleted, :metadata, :slug]).merge(sy_club_extra_fields)
      }
    end

    # GET /sy_clubs/new
    def new
      @sy_club = SyClub.new
    end

    # GET /sy_clubs/1/edit
    def edit
    end

    # POST /sy_clubs
    def create
      @sy_club = SyClub.new(sy_club_params.merge(user_id: current_user.try(:id)))
      authorize @sy_club
      if @sy_club.save
        render json: @sy_club
      else
        render json: @sy_club.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end

    # PATCH/PUT /sy_clubs/1
    def update
      authorize @sy_club
      if @sy_club.update(sy_club_params)
        render json: @sy_club
      else
        render json: @sy_club.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end

    # DELETE /sy_clubs/1
    def destroy
      authorize @sy_club
      if @sy_club.update_columns(is_deleted: true)
        render json: @sy_club
      else
        render json: @sy_club.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end

    def join_club
      if join_club_params.has_key?('sadhak_profiles') and join_club_params[:sadhak_profiles].present?
        @joined_sadhak_profiles =  []
        errors = []
        @sadhak_profiles = join_club_params[:sadhak_profiles]
        club = SyClub.find_by_id(@sadhak_profiles.first[:sy_club_id]) if @sadhak_profiles.count and @sadhak_profiles.first[:sy_club_id].present?
        if club.present?
          if true
            if club.address.present?
              if club.address.country_id == 113
                errorObj= {sy_club: ["India forum registration is disabled on #{Rails.application.config.app_base_url}. Please visit http://sadhak.shivyog.com for registration."]}
                render json:  errorObj, status: :unprocessable_entity
              else
                errorObj= {sy_club: ["#{club.address.country_name} forum registration is disabled on https://www.shivyogportal.com. Please contact board members."]}
                render json:  errorObj, status: :unprocessable_entity
              end
            else
              errorObj= {sy_club_address: ['Forum address missing. Please contact to board members.']}
              render json:  errorObj, status: :unprocessable_entity
            end
          elsif club.status == 'enabled'
            @sadhak_profiles.each do |profile|
              sy_club_member = SyClubMember.where(sy_club_id: profile['sy_club_id'], sadhak_profile_id: profile['sadhak_profile_id']).last
              if sy_club_member.present? and sy_club_member.status == 'approve'
                message = "Name: #{sy_club_member.sadhak_profile.first_name} and SYID: #{sy_club_member.sadhak_profile.syid} already registered for this forum"
                errors.push(message)
              end
            end
            if errors.count == 0
              @sadhak_profiles.each do |profile|
                 @sy_club_members = SyClubMember.find_or_create_by(sy_club_id: profile['sy_club_id'], sadhak_profile_id: profile['sadhak_profile_id'])
                @joined_sadhak_profiles.push(@sy_club_members)
              end
              render json: @joined_sadhak_profiles
            else
              errorObj= {errors:{Profile: errors}}
              render json:  errorObj, status: :unprocessable_entity
            end
          elsif club.status == 'disabled'
            errorObj= {sy_club_status: ['Current forum is not active. Please contact to board members.']}
            render json:  errorObj, status: :unprocessable_entity
          elsif club.status == 'capacity_reached'
            errorObj= {sy_club_status: ['Forum capacity is already reached. Please contact to board members.']}
            render json:  errorObj, status: :unprocessable_entity
          else
            errorObj= {error: ['Some error occured while processing your request. Please contact to board members.']}
            render json:  errorObj, status: :unprocessable_entity
          end
        else
          errorObj= {sy_club_id: ["Forum you are trying to join is doesn't exist. Please contact to board members."]}
          render json:  errorObj, status: :unprocessable_entity
        end
      else
        errorObj= {sadhak_profiles: ['Parameter missing.']}
        render json:  errorObj, status: :unprocessable_entity
        return false
      end
    end

    # This will make a registration for forum if sadhak already purchased a product.
    def forum_register
      begin
        # Hold joined sadhaks
        @joined_sadhak_profiles = []

        # Parameters checking
        raise SyException, 'Please provide sadhak profiles to register.' unless join_club_params[:sadhak_profiles].present?
        raise SyException, 'Please select a valid forum.' unless join_club_params[:sy_club_id].present?
        raise SyException, 'Please input a valid email for registration.' unless (join_club_params[:guest_email].present? and join_club_params[:guest_email].is_valid_email?)
        raise SyException, 'Please provide a membership start date and end date.' unless join_club_params[:sy_club_validity_window_id].present?

        # Find club in database
        club = SyClub.where(id: join_club_params[:sy_club_id]).includes(:approved_members, :address).last
        raise SyException, "Forum you are trying to join is doesn't exist. Please contact to board members." unless club.present?

        # Raise error if club is disabled, capacity_reached
        raise SyException, 'Current forum is not active. Please contact to board members.' if club.disabled?
        raise SyException, 'Forum capacity is already reached. Please contact to board members.' if club.capacity_reached?
        raise SyException, 'Forum address does not found. Please contact to board members.' unless club.address.present?

        # Check whether joining sadhak profiles are registered to CLP
        # event_ids = GlobalPreference.where(key: %w(india_clp_events global_clp_events)).pluck(:val).join(',').split(',').map{|i| i.to_i}
        sadhak_profiles = SadhakProfile.where(id: join_club_params[:sadhak_profiles])

        # To get value of india and global events
        india_event_ids = GlobalPreference.get_value_of('india_clp_events').to_s.split(',').map{|i| i.to_i}
        global_event_ids = GlobalPreference.get_value_of('global_clp_events').to_s.split(',').map{|i| i.to_i}

        event_ids = india_event_ids + global_event_ids

        # Iterate over provided sadhak profile ids to check that sadhak purchased a procut or not.
        join_club_params[:sadhak_profiles].each do |sp_id|

          # Find sadhak profile from collection
          sadhak_profile = sadhak_profiles.find{|sp| sp.try(:id) == sp_id.try(:to_i)}

          # To check whether sadhak is already a member of any forum or not
          member = SyClubMember.where(sadhak_profile_id: sadhak_profile.id, status: 1)

          # Collect CLP registrations
          india_registrations = sadhak_profile.event_registrations.where(event_id: india_event_ids, status: EventRegistration.valid_registration_statuses)

          global_registrations = sadhak_profile.event_registrations.where(event_id: global_event_ids, status: EventRegistration.valid_registration_statuses)

          # Raise exception if sadhak registered to any of global and india clp event, and also a forum member
          raise SyException, "Profile: Name: #{sadhak_profile.try(:full_name)} and SYID: #{sadhak_profile.try(:syid)} did not attend any clp event, So this profile can't register on forum." unless (event_ids & sadhak_profile.event_ids).present?

          # Raise error is sadhak already registered to same
          raise SyException, "Profile: Name: #{sadhak_profile.try(:full_name)} and SYID: #{sadhak_profile.try(:syid)} already registered for this forum." if club.approved_members.include?(sadhak_profile)

          # Raise error is sadhak already regitered to any forum
          raise SyException, "Profile: Name: #{sadhak_profile.try(:full_name)} and SYID: #{sadhak_profile.try(:syid)} already a forum member of some other forum." if (member.present? and member.length > 0)

          if club.address.country_id == 113
            raise SyException, "Profile: Name: #{sadhak_profile.try(:full_name)} and SYID: #{sadhak_profile.try(:syid)} is not purchased india CLP." if india_registrations.size == 0
          else
            raise SyException, "Profile: Name: #{sadhak_profile.try(:full_name)} and SYID: #{sadhak_profile.try(:syid)} is not purchased global CLP." if global_registrations.size == 0
          end

        end

        # If all success than make sadhak as approved member of this forum.
        ActiveRecord::Base.transaction do
          join_club_params[:sadhak_profiles].each do |sp_id|

            # Find sadhak entery if available with status pending
            sy_club_member = club.sy_club_members.where(sadhak_profile_id: sp_id, status: SyClubMember.statuses['pending']).last

            # If found update existing else create new one with provided details
            if sy_club_member.present?
               sy_club_member.update(status: SyClubMember.statuses['approve'], guest_email: join_club_params[:guest_email], sy_club_validity_window_id: join_club_params[:sy_club_validity_window_id], club_joining_date: DateTime.now)
            else
               sy_club_member = club.sy_club_members.create(status: SyClubMember.statuses['approve'], guest_email: join_club_params[:guest_email], sy_club_validity_window_id: join_club_params[:sy_club_validity_window_id], club_joining_date: DateTime.now, sadhak_profile_id: sp_id)
            end

            # Raise error is there any error while creating or updating member details.
            raise SyException, "Some error occured while creating registration : #{sy_club_member.errors.as_json(full_messages: true).first}" unless sy_club_member.errors.empty?

            if club.address.country_id == 113
              registration = EventRegistration.where(sadhak_profile_id: sp_id, event_id: india_event_ids, status: EventRegistration.valid_registration_statuses).last
            else
              registration = EventRegistration.where(sadhak_profile_id: sp_id, event_id: global_event_ids, status: EventRegistration.valid_registration_statuses).last
            end

            # Update data
            validity_days = registration.event.get_clp_detail[:validity_days] + (Date.today - registration.created_at.to_date).to_i

            registration.update_columns(expires_at: validity_days)

            sy_club_member.update_columns(event_registration_id: registration.id)

            # Push successfully joined sadhaks to array
            @joined_sadhak_profiles.push(sy_club_member)
          end
        end

        # Send email to board members organisers and registered sadhaks
        begin
          # Extract valid email
          # If environment is production don't change emails
          if Rails.env == 'production'
            organizers_email = club.board_member_emails.extract_valid_emails
            members_email = sadhak_profiles.pluck(:email).extract_valid_emails
            guest_email = join_club_params[:guest_email]
          elsif Rails.env == 'development'
            organizers_email = club.board_member_emails.extract_valid_emails + ['prince@metadesignsolutions.in']
            members_email = sadhak_profiles.pluck(:email).extract_valid_emails + ['prince@metadesignsolutions.in']
            guest_email = join_club_params[:guest_email]
          end
          if organizers_email.count > 0 or members_email.count > 0 or guest_email.is_valid_email?
            from = GetSenderEmail.call(club)
            ApplicationMailer.send_email(from: from, recipients: guest_email, cc: members_email, subject: "Forum (#{club.name}) payment has been received ##{sadhak_profiles.collect{|s| s.syid}.join(',')} - #{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}", template: 'forum_register', sadhak_profiles: sadhak_profiles, club: club).deliver

            ApplicationMailer.send_email(from: from, recipients: organizers_email, subject: "Forum (#{club.name}) payment has been received ##{sadhak_profiles.collect{|s| s.syid}.join(',')} - #{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}", template: 'forum_register', sadhak_profiles: sadhak_profiles, club: club).deliver
          end
        rescue Exception => e
          logger.info(e)
          logger.info(e.backtrace.inspect)
          logger.info('Error in sending Email.')
        end

      # Handle manual as well as Runtime exceptions
      rescue SyException => e
        logger.info("Manual Exception: #{e.message}")
        is_error = true
        message = e.message
      rescue Exception => e
        logger.info("Runtime exception: #{e.message}")
        logger.info(e.backtrace.inspect)
        is_error = true
        message = e.message
      end

      # If there is any error
      if is_error
        render json: {error: [message]}, status: :unprocessable_entity
      else
        render json: @joined_sadhak_profiles
      end
    end

    def club_payment
      gateway = TransferredEventOrder.gateways.find{|g| g[:symbol] == params[:method]}
      if gateway.present?
        if payment_detail_params.has_key?('sy_club_id') and payment_detail_params.has_key?('amount') and payment_detail_params.has_key?('config_id') and payment_detail_params[:sy_club_id].present? and payment_detail_params[:amount].present? and payment_detail_params[:config_id].present? and payment_detail_params.has_key?('association_ids') and payment_detail_params[:association_ids].present? and payment_detail_params.has_key?('guest_email') and payment_detail_params[:guest_email].present?
          # Make a log for this transaction
          @transaction_log = TransactionLog.create(transaction_loggable_id: payment_detail_params[:sy_club_id], transaction_loggable_type: controller_name.classify.to_s, other_detail: other_detail, transaction_type: TransactionLog.transaction_types[:pay], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol])
          club = SyClub.find_by_id(payment_detail_params[:sy_club_id])
          if club.present?
            message = club.check_for_already_paid(payment_detail_params[:association_ids])
            if message.present?
              errorObj= {errors:{error: [message]}}
              render json:  errorObj, status: :unprocessable_entity
            else
              if gateway[:symbol] == 'paypal'
                render json: {transaction_log_id: @transaction_log.id}
              else
                payment, message = gateway[:controller].constantize.new.create(payment_detail_params, @transaction_log)
                if message.nil?
                  is_update_success, err_message = SyClub.new.after_club_payment(payment, message, payment_detail_params)
                  if is_update_success
                    render json: payment
                  else
                    err_message = payment.status == 'success' ? "Your payment has been recieved but #{err_message}. Please don't pay again and contact to ashram." : err_message
                    render json: {error: [err_message]}, status: :unprocessable_entity
                  end
                else
                  errorObj= {errors:{error: [message]}}
                  render json:  errorObj, status: :unprocessable_entity
                end
              end
            end
          else
            errorObj= {errors:{error: ['No club found.']}}
            render json:  errorObj, status: :unprocessable_entity
          end
        else
          errorObj= {errors:{error: ['Please input all required details']}}
          render json:  errorObj, status: :unprocessable_entity
        end
      else
        errorObj= {errors:{error: ['Not a valid payment method']}}
        render json:  errorObj, status: :unprocessable_entity
      end
    end

    def other_detail
      sadhak_profile_ids = SyClubMember.where(id: payment_detail_params[:association_ids]).pluck(:sadhak_profile_id)
      {amount: payment_detail_params[:amount], sy_club_id: payment_detail_params[:sy_club_id], association_ids: payment_detail_params[:association_ids], guest_email: payment_detail_params[:guest_email], sadhak_profile_ids: sadhak_profile_ids, payment_detail_params: payment_detail_params, config_id: payment_detail_params[:config_id]}
    end

    def check_transfer
      begin
        data = SyClub.last.check_transfer(forum_transfer_params)
      rescue SyException => e
        is_error = true
        result = e.message
      rescue Exception => e
        is_error = true
        result = e.message
        logger.info(e.backtrace)
      end

      if is_error
        render json: {error: [result]}, status: :unprocessable_entity
      else
        render json: data
      end
    end

    def forum_transfer
      begin

        #Get forum details
        sy_club = SyClub.where(id: forum_transfer_params[:sy_club_id]).includes(:approved_members, { address: [:db_city, :db_state, :db_country] }).last
        raise SyException, "Forum not found with id: #{forum_transfer_params[:sy_club_id]}" unless sy_club.present?

        data = sy_club.check_transfer(forum_transfer_params)

        # To ensure that all sadhak belongs to India only or outside only.
        sadhak_profiles = SadhakProfile.where(syid: forum_transfer_params[:sadhak_profiles].collect{|s| s.syid}).includes({ address: [:db_city, :db_state, :db_country]})
        raise SyException, 'Sadhak Profiles not found.' unless sadhak_profiles.present?

        # Verify that sadhak profiles already registered for this forum.
        data[:data].each do |info|

          profile = sadhak_profiles.find{|sp| sp.syid == info[:syid]}
          raise SyException, "Sadhak Profile not found with SYID: #{info[:syid]}" unless profile.present?

          raise SyException, "#{profile.syid} is already registered to #{sy_club.name}" if sy_club.approved_members.include?(profile)

          raise SyException, "#{profile.syid} is not eligible for transfer on #{sy_club.name}" unless info[:can_transfer]

        end

        raise SyException, 'Some profile(s) are eligible for transfer/renew and some are new registration(s). cannot process together. Aborting.' if (not data[:fresh_registration] and not data[:can_transfer] and not data[:can_renew])

        raise SyException, 'Not a forum transfer request. Aborting.' unless data[:can_transfer]

        success = sy_club.do_transfer(data.merge(guest_email: forum_transfer_params[:guest_email]))

      rescue SyException => e
        is_error = true
        result = e.message
      rescue Exception => e
        is_error = true
        result = e.message
      end

      if is_error
        render json: {error: [result]}, status: :unprocessable_entity
      else
        render json: success
      end
    end

    def content_types
      render json: %w(english hindi bengali other)
    end

    def locate_collection
      if params[:page].present?
        @sy_clubs = Api::V1::ShivyogClub::SyClubPolicy::Scope.new(current_user, SyClub).resolve(filtering_params).order(:id).distinct.page(params[:page]).per(params[:per_page])
      else
        @sy_clubs = Api::V1::ShivyogClub::SyClubPolicy::Scope.new(current_user, SyClub).resolve(filtering_params).order(:id).distinct

      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sy_club
        @sy_club = SyClub.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def sy_club_params
        params.require(:sy_club).permit(:name, :min_members_count, :content_type, :status_notes, :members_count, :status,  :email, :contact_details, :event_ids,  :sadhak_profile_reference_ids, :event_type_ids, :other_activity, :cultural_activities, :sy_club_digital_arrangement_detail, :sadhak_profile_reference_ids => [], :event_ids => [], :event_type_ids => [])
      end

      def join_club_params
        params.require(:join_club_detail).permit!#(:sy_club_id, :sadhak_profile_ids, :sadhak_profile_ids => [])
      end

      def payment_detail_params
        params.require(:payment_details).permit!
      end

      def filtering_params
        params.slice(:sy_club_id, :state_id, :country_id, :city_id, :lat, :lng, :sy_club_name, :status).select{|k, v| v.present?}
      end

      def forum_transfer_params
        params.require(:event_order).permit!
      end

      def get_sadhak_profile_associations
        sy_club_sadhak_profile_associations = []
        @sy_club.sy_club_sadhak_profile_associations.each do |profile_assoc|
          assoc_profile = {}
           profile = profile_assoc.sadhak_profile
          next if profile.blank?
          assoc_profile = profile_assoc.as_json(:except => [:created_at, :updated_at, :is_joined, :deleted_at])
          assoc_profile[:first_name] = profile.last_name
          assoc_profile[:last_name] = profile.last_name
          unless assoc_profile.empty?
            sy_club_sadhak_profile_associations << assoc_profile
          end
        end
        sy_club_sadhak_profile_associations
      end
  end
end
