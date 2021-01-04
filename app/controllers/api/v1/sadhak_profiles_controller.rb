module Api::V1
  class SadhakProfilesController < ApplicationController
    require 'securerandom'
    require 'msg91ruby'
    respond_to :json
    # $flag = 0
    before_action :authenticate_user!, except: [:index, :create, :request_mobile_verification,  :confirm_mobile_verification, :request_email_verification,  :confirm_email_verification, :update, :notify_sadhak_profiles, :search_syid_using_mobile_or_email, :wp_sadhak_profile, :wp_sadhak_profile_search, :generate_card]
    before_action :locate_collection, :only => [:index]
    before_action :set_sadhak_profile, only: [:show, :edit, :update, :destroy, :request_mobile_verification,  :confirm_mobile_verification, :request_email_verification,  :confirm_email_verification, :wp_sadhak_profile]
    skip_before_action :verify_authenticity_token, :only => [:index, :create, :request_mobile_verification,  :confirm_mobile_verification, :request_email_verification,  :confirm_email_verification, :update, :notify_sadhak_profiles, :search_syid_using_mobile_or_email, :wp_sadhak_profile, :wp_sadhak_profile_search, :generate_card]

    # GET /sadhak_profiles
    def index
      if params.has_key?('status') and params[:status] == 'pending' and current_user.present? and current_user.photo_approval_admin?
        @sadhak_profiles = SadhakProfile.where('address_proof_status = 0 OR  photo_id_status = 0 OR profile_photo_status = 0').includes({address: [:db_city, :db_state, :db_country] }, {advance_profile: [:advance_profile_photograph, :advance_profile_identity_proof, :advance_profile_address_proof]}, :relations).page(params[:page]).per(10)
        render json: @sadhak_profiles, each_serializer: UnapprovedSadhakProfileSerializer
        return false
      end
      if params.has_key?('mode') and params[:mode] == 'simple_search'
        search_for_order
      elsif params.has_key?('mode') and params[:mode] == 'basic_simple_search'
          basic_simple_search
      elsif params.has_key?('mode') and params[:mode] == 'search_syid'
        search_syid
      elsif params.has_key?('mode') and params[:mode] == 'mini_search_syid'
        mini_search_syid
      elsif params.has_key?('mode') and params[:mode] == 'sadhak_search' and current_user.present? and (current_user.super_admin? or current_user.is_country_admin?)
        render json: @qsadhak_profiles.order('sadhak_profiles.id').page(params[:page]).per(params[:per_page]), serializer: PaginationSerializer
      elsif params.has_key?('sy_club_id') and params[:sy_club_id].present?
        @sadhak_profiles = SadhakProfile.includes(:sy_club_members, { professional_detail: [:profession] }).joins(:joined_clubs).where('sy_club_members.sy_club_id = ?', params[:sy_club_id])
        render json: @sadhak_profiles, each_serializer: ClubMemberSerializer
      elsif params.has_key?('mode') and params[:mode] == 'sadhak_search' and current_user.present? and current_user.sadhak_profile.present? and current_user.valid_registered_center_event_ids.count > 0
        render json: @qsadhak_profiles.order('sadhak_profiles.id').page(params[:page]).per(params[:per_page]), serializer: PaginationSerializer
      elsif current_user.present?
        @sadhak_profile_ids = current_user.sadhak_profiles.pluck(:id)
        if current_user.sadhak_profile
          @sadhak_profile_ids.push(current_user.sadhak_profile.id)
        end
        @sadhak_profiles = SadhakProfile.where(id: @sadhak_profile_ids).includes(SadhakProfile.includable_data)
        render json: @sadhak_profiles
      else
        render json: []
      end
    end

    def show
      # Added on Nov 6, 2016 Email: Security Bug
      authorize @sadhak_profile
      @sadhak_profile = SadhakProfile.find(params[:id])
      render json: @sadhak_profile
    end

    def me
      @sadhak_profile = current_user.sadhak_profile
      render json: @sadhak_profile
    end

    def wp_sadhak_profile
      # authorize @sadhak_profile
      # render json: @sy_club
      address = @sadhak_profile.try(:address).as_json(:except => [:created_at, :updated_at, :district, :deleted_at, :address_type])
      address_extra_field = @sadhak_profile.try(:address).try(:slice, :db_state_id, :db_city_id, :db_country_id)
      city_fields = @sadhak_profile.try(:address).try(:db_city).try(:slice, :id, :state_id, :country_id, :name)
      state_fields = @sadhak_profile.try(:address).try(:db_state).try(:slice, :id, :country_id, :name)
      country_fields = @sadhak_profile.try(:address).try(:db_country).try(:slice, :id, :name, :telephone_prefix, :currency, :currency_code)
      @sadhak_profile = @sadhak_profile.slice(:id, :syid, :first_name, :middle_name, :last_name, :date_of_birth, :mobile, :email, :username, :active_club_ids, :joined_club_ids, :sy_club_ids, :address_id).merge(address_id: @sadhak_profile.try(:address).id)

      render json: {}.merge(
        **{sadhak_profile: @sadhak_profile},
        **{ addresses: [address.merge(address_extra_field)] },
        **{ db_cities: [city_fields] },
        **{ db_states: [state_fields] },
        **{ db_countries: [country_fields] }
      )
    end

    def update
      # lokesh
      #     authorize @sadhak_profile
      profile_params = sadhak_profile_update_params
      relation_type = profile_params["relationship_type"]
      profile_params.delete(:relationship_type)
      if @sadhak_profile.update(profile_params)
        if relation_type.present? and relation_type != 'self' and current_user.present?
          @sadhak_relation = @sadhak_profile.relations.find_by(:user_id => current_user.id)
          if @sadhak_relation
            @sadhak_relation.update(relationship_type: relation_type)
          else
            relation_params = {:relationship_type => relation_type, :sadhak_profile_id => @sadhak_profile.id, :user_id => current_user.id}
            @sadhak_profile.relations.create(relation_params)
          end
        end
        # Visit.create(@sadhak_profile, current_visit)
        render json: @sadhak_profile
      else
        render json: @sadhak_profile.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end

    def create
      profile_params = sadhak_profile_create_params
      relation_type = profile_params[:relationship_type]
      profile_params.delete(:relationship_type)
      if relation_type == 'self'
        profile_params[:user_id] = current_user.id
      end
      @sadhak_profile = SadhakProfile.new(profile_params)
      if @sadhak_profile.save
        if relation_type != 'self' and current_user.present?
          relation_params = {:relationship_type => relation_type, :user_id => current_user.id, :is_verified => true}
          @sadhak_profile.relations.create(relation_params)
        end
        render json: @sadhak_profile
      else
        render json: @sadhak_profile.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end


    def edit
        @sadhak_profile = current_user.sadhak_profile
    end

    def request_mobile_verification
      begin
        raise 'Sadhak Profile not found.' unless @sadhak_profile.present?
        raise 'Please fill/save address details first.' unless @sadhak_profile.address.present?
        raise "Mobile already verified for #{@sadhak_profile.syid}" if @sadhak_profile.is_mobile_verified?
        mobile_verification_token = SecureRandom.random_number(1000000)
        @sadhak_profile.mobile_verification_token = mobile_verification_token
        raise @sadhak_profile.errors.full_messages.first unless @sadhak_profile.save
        raise 'Error occured while sending message.' unless @sadhak_profile.send_sms_to_sadhak("NMS #{@sadhak_profile.full_name}\nSHIVYOG - Mobile verification code is: #{mobile_verification_token}")
      rescue Exception => e
        Rails.logger.info("Sadhak Profile: request_mobile_verification - Exception: #{e.message}")
        is_error = true
        message = e.message
      end

      if is_error
        custom_error(key: 'mobile_verification', message: message)
      else
        custom_success(key: 'Mobile', message: 'verification code has been sent successfully.')
      end
    end

    def confirm_mobile_verification
      begin
        raise 'Sadhak Profile not found.' unless @sadhak_profile.present?
        raise 'Please fill/save address details first.' unless @sadhak_profile.address.present?
        raise "Mobile already verified for #{@sadhak_profile.syid}" if @sadhak_profile.is_mobile_verified?
        raise 'Mobile verification token missing.' unless params[:mobile_verification_token].present?
        @verify_by_rc = @sadhak_profile.verify_by_rc(current_user, params[:rc_event_id])
        raise 'Verification token does not match' unless params[:mobile_verification_token] == @sadhak_profile.mobile_verification_token || @verify_by_rc
        @sadhak_profile.is_mobile_verified = true
        raise @sadhak_profile.errors.full_messages.first unless @sadhak_profile.save
        raise "User not found for #{@sadhak_profile.syid}" unless @sadhak_profile.user.present?
        if @sadhak_profile.user.email.blank? && @sadhak_profile.user.contact_number.nil?
          update_user
        end
      rescue Exception => e
        Rails.logger.info("Sadhak Profile: confirm_mobile_verification - Exception: #{e.message}")
        is_error = true
        message = e.message
      end
      if is_error
        custom_error(key: 'mobile_verification', message: message)
      else
        custom_success(key: 'mobile_verification', message: 'Information successfully verified.')
      end
    end

    def request_email_verification
      begin
        raise 'Sadhak Profile not found.' unless @sadhak_profile.present?
        raise 'Please fill/save address details first.' unless @sadhak_profile.address.present?
        raise "Email already verified for #{@sadhak_profile.syid}" if @sadhak_profile.is_email_verified?
        @email_verification_token = SecureRandom.random_number(1000000)
        @sadhak_profile.email_verification_token = @email_verification_token
        raise @sadhak_profile.errors.full_messages.first unless @sadhak_profile.save
        UserMailer.sadhak_email_confirmation_notice(@sadhak_profile).deliver!
      rescue Exception => e
        Rails.logger.info("Sadhak Profile: request_email_verification - Exception: #{e.message}")
        is_error = true
        message = e.message
      end

      if is_error
        custom_error(key: 'email_verification', message: message)
      else
        custom_success(key: 'Email', message: 'verification code has been sent successfully.')
      end
    end

    def confirm_email_verification
      begin
        raise 'Sadhak Profile not found.' unless @sadhak_profile.present?
        raise 'Please fill/save address details first.' unless @sadhak_profile.address.present?
        raise "Email already verified for #{@sadhak_profile.syid}" if @sadhak_profile.is_email_verified?
        raise 'Email verification token missing.' unless params[:email_verification_token].present?
        @verify_by_rc = @sadhak_profile.verify_by_rc(current_user, params[:rc_event_id])
        raise 'Verification token does not match' unless params[:email_verification_token] == @sadhak_profile.email_verification_token || @verify_by_rc
        @sadhak_profile.is_email_verified = true
        raise @sadhak_profile.errors.full_messages.first unless @sadhak_profile.save
        raise "User not found for #{@sadhak_profile.syid}" unless @sadhak_profile.user.present?
        if @sadhak_profile.user.email.blank? && @sadhak_profile.user.contact_number.nil?
          update_user
        end
      rescue Exception => e
        Rails.logger.info("Sadhak Profile: confirm_email_verification - Exception: #{e.message}")
        is_error = true
        message = e.message
      end
      if is_error
        custom_error(key: 'email_verification', message: message)
      else
        custom_success(key: 'email_verification', message: 'Information successfully verified.')
      end
    end

    def request_own_profile
      # if own_profile_params.has_key?("syid") and own_profile_params.has_key?("first_name")
      #   @sadhak_profile = SadhakProfile.where("LOWER(syid) = ? and LOWER(first_name) = ?", own_profile_params[:syid].downcase, own_profile_params[:first_name].downcase).first
      #   if @sadhak_profile.present?
      #     @ownership_request_token = SecureRandom.random_number(1000000)
      #     @sadhak_profile.ownership_request_token = @ownership_request_token
      #     if @sadhak_profile.save
      #       UserMailer.sadhak_profile_ownership_request(@sadhak_profile).deliver
      #       #send response
      #       render json: {success: 1, ownership_request_token: @sadhak_profile.ownership_request_token}
      #     else
      #       render json: {error: 1, message: 'Token generation failed.', e: @sadhak_profile.errors}, status: :unprocessable_entity
      #     end
      #   else
      #     render json: {error: 1, message: "Sadhak profile not found."}, status: 404
      #   end
      # else
      #   render json: {error: 1, message: "Sadhak profile not found."}, status: 404
      # end
      render json: {error: 1, message: "This request cannot be processed. Please contact Ashram."}, status: 422
    end

    def confirm_own_sadhak_profile
      # if own_profile_params.has_key?("syid") and own_profile_params.has_key?("first_name") and own_profile_params.has_key?("ownership_request_token")
      #   @sadhak_profile = SadhakProfile.where("LOWER(syid) = ? and LOWER(first_name) = ?", own_profile_params[:syid].downcase, own_profile_params[:first_name].downcase).first
      #   if @sadhak_profile.present?
      #     if @sadhak_profile.ownership_request_token == own_profile_params[:ownership_request_token]
      #       # if current user is already associated with a self related sadhak_profile
      #       if current_user.sadhak_profile.present?
      #         current_sadhak_profile = current_user.sadhak_profile
      #         current_sadhak_profile.user_id = nil
      #         current_sadhak_profile.save
      #       end
      #       # if current user has the sadhak profile in its related profile, remove it from there
      #       if current_user.sadhak_profiles.include?(@sadhak_profile)
      #         Relation.find_by(:user_id => current_user.id, :sadhak_profile_id => @sadhak_profile.id).destroy
      #       end
      #       @sadhak_profile.user_id = current_user.id
      #       @sadhak_profile.ownership_request_token = nil
      #       if @sadhak_profile.save
      #         render json: {success: 1}
      #       else
      #         render json: {error: 1, message: 'Something went wrong'}, status: :unprocessable_entity
      #       end
      #     else
      #       render json: {error: 1, message: 'Ownership request token does not match.'}, status: :unprocessable_entity
      #     end
      #   else
      #     render json: {error: 1, message: "Sadhak profile not found."}, status: 404
      #   end
      # else
      #   render json: {error: 1, message: "Sadhak profile not found."}, status: 404
      # end
      render json: {error: 1, message: "This request cannot be processed. Please contact Ashram."}, status: 422
    end

    def simple_search
      @sadhak_profiles = []
      if search_for_order_params.has_key?('syid') and search_for_order_params[:syid].present?
        syid = search_for_order_params[:syid].strip
        syid = syid[/-?\d+/].to_i
        syid = "sy#{syid}"

        if search_for_order_params.has_key?('first_name') and search_for_order_params[:first_name].present?
          f_name = search_for_order_params[:first_name].strip
          @sadhak_profiles = SadhakProfile.where('LOWER(syid) = ? and LOWER(first_name) = ?', syid.downcase, f_name.downcase).includes(:relations)
        elsif search_for_order_params.has_key?('mobile') and search_for_order_params[:mobile].present?
          mobile = search_for_order_params[:mobile]
          @sadhak_profiles = SadhakProfile.where('LOWER(syid) = ? and mobile = ?', syid.downcase, mobile).includes(:relations)
        elsif search_for_order_params.has_key?('date_of_birth') and search_for_order_params[:date_of_birth].present?
          dob = search_for_order_params[:date_of_birth].strip.to_date
          @sadhak_profiles = SadhakProfile.where('LOWER(syid) = ? and date_of_birth = ?', syid.downcase, dob).includes(:relations)
        elsif current_user.present? and search_for_order_params.has_key?('rc_event_id') and !search_for_order_params[:rc_event_id].nil?
          verified_rc = SadhakProfile.new.verify_by_rc(current_user, search_for_order_params[:rc_event_id])
          if verified_rc
            @sadhak_profiles = SadhakProfile.where('LOWER(syid) = ?', syid.downcase).includes(:relations)
          end
        end
      end
    end

    def search_for_order
      simple_search
      render json: @sadhak_profiles
    end

    def basic_simple_search
      simple_search
      render json: @sadhak_profiles, each_serializer: BasicDetailSadhakProfileSerializer, root: 'sadhak_profiles'
    end

    def wp_sadhak_profile_search
      simple_search
      render json: @sadhak_profiles, each_serializer: WpSadhakProfileSearchSerializer, root: 'sadhak_profiles'
    end

    def add_to_user
      if add_user_params.has_key?("syid") and add_user_params.has_key?("first_name")
        @sadhak_profile = SadhakProfile.where("LOWER(syid) = ? and LOWER(first_name) = ?", add_user_params[:syid].downcase, add_user_params[:first_name].downcase).first
        if @sadhak_profile.present?
          @address = @sadhak_profile.address
          if @address.present?
            @db_country = @address.country_id
            telephone_prefix = DbCountry.find(@db_country).telephone_prefix
          else
            render json: {message: "No address found"}
          end
          if @sadhak_profile.is_email_verified? and  @sadhak_profile.is_mobile_verified?
            @relation = @sadhak_profile.add_to_user(current_user)
            if @relation.nil?
              #                render json: {success: 0, message: "Could not be added."}
              res = SendSms.call(@sadhak_profile.mobile, telephone_prefix, "SHIVYOG - Mobile verification code is " + @relation.verification_code.to_s, 'IN')
              UserMailer.sadhak_profile_association_verification(@sadhak_profile, @relation).deliver
            else
              res = SendSms.call(@sadhak_profile.mobile, telephone_prefix, "SHIVYOG - Mobile verification code is " + @relation.verification_code.to_s, 'IN')
              UserMailer.sadhak_profile_association_verification(@sadhak_profile, @relation).deliver
              render json: {success: 0, message: "verification code send to email and mobile"}
            end
          else
            if @sadhak_profile.is_email_verified?
              @relation = @sadhak_profile.add_to_user(current_user)
              if @relation.nil?  UserMailer.sadhak_profile_association_verification(@sadhak_profile, @relation).deliver
                #                 render json: {success: 0, message: "Could not be added."}
              else
                UserMailer.sadhak_profile_association_verification(@sadhak_profile, @relation).deliver
                render json: {success: 0, message: "verification code send to email"}
              end
            else @sadhak_profile.is_mobile_verified?
              @relation = @sadhak_profile.add_to_user(current_user)
              if @relation.nil?
                res = SendSms.call(@sadhak_profile.mobile, telephone_prefix, "SHIVYOG - Mobile verification code is " + @relation.verification_code.to_s, 'IN')
                #                render json: {success: 0, message: "Could not be added."}
              else
                res = SendSms.call(@sadhak_profile.mobile, telephone_prefix, "SHIVYOG - Mobile verification code is " + @relation.verification_code.to_s, 'IN')

                render json: {success: 0, message: "verification code send to mobile"}
              end
            end
          end
        else
          render json: {success: 0, message: "Sadhak profile does not exist."}
        end
      else
        render json: {error: 1, message: "Sadhak profile not found."}, status: 404
      end
    end

    def sadhak_profile_confirm_association
      if confirm_sadhak_profile_params.has_key?('syid') and confirm_sadhak_profile_params.has_key?('verification_code')
        @relation = Relation.where("LOWER(syid) = ? ", add_user_params[:syid].downcase).last
        if @relation.verification_code == confirm_sadhak_profile_params[:verification_code]
          @relation.is_verified = 'true'
          if @relation.save
            render json: @relation
          else
            render json: {message: "sadhak_profile not verified"}
          end
        else
          render json: {message: "Check verification code"}
        end
      else
        render json:  {message: "send all values"}
      end
    end

    def update_user
      password = Devise.friendly_token.first(8)
      @age = ((DateTime.now.to_date.year - User.find(@sadhak_profile.user_id).date_of_birth.to_date.year)/365).floor
      if @sadhak_profile.user.email.blank? && @sadhak_profile.email.present? && @sadhak_profile.is_email_verified = true
        user = User.find(@sadhak_profile.user_id).update_attributes(email: @sadhak_profile.email, is_email_verified: true, password: password, is_mobile_verified: false)
        @email = User.find(@sadhak_profile.user_id).email
        @user = User.find(@sadhak_profile.user_id)
        from = GetSenderEmail.call(@sadhak_profile)
        ApplicationMailer.send_email(from: from, recipients: @email, sadhak_profile: @sadhak_profile, template: 'welcome', subject: "Welcome to Shivyog #{@sadhak_profile.syid}").deliver
      end
      if @sadhak_profile.user.contact_number.blank? && @sadhak_profile.mobile.present?
        @sadhak_profile.is_mobile_verified = true
        @username = User.find(@sadhak_profile.user_id).username
        @password = password
        user = User.find(@sadhak_profile.user_id).update_attributes(contact_number: @sadhak_profile.mobile, is_mobile_verified: true, password: password, is_email_verified: false)
        age = ((DateTime.now.to_date.year - @sadhak_profile.date_of_birth.to_date.year)/365).floor
        telephone_prefix = @sadhak_profile.address.db_country.telephone_prefix
        country_code = @sadhak_profile.address.db_country.ISO2
        if @age >= SADHAK_MIN_AGE
          res = SendSms.call(@sadhak_profile.mobile, telephone_prefix, "Account successfully created " + "\nusername:" + @username.to_s, country_code.to_s)
        else
          res = SendSms.call(@sadhak_profile.mobile, telephone_prefix, "Account successfully created " + "\nfirstname: " + @sadhak_profile.first_name + "\nsyid: " + @sadhak_profile.syid, country_code.to_s)
        end
      end
    end

    def search_syid
      begin
        raise 'First Name cannot be blank.' unless params[:first_name].present?
        raise 'Date of birth cannot be blank.' unless params[:date_of_birth].present?

        if (Date.parse(params[:date_of_birth].to_s) rescue ArgumentError) == ArgumentError
          raise "Date of birth is not a valid date (#{params[:date_of_birth].to_s})"
        end
        date_of_birth = Date.parse(params[:date_of_birth].to_s)
        unless date_of_birth <= Date.today and date_of_birth >= Date.new(1900,1,1)
          raise "Date of birth should be greater than or equal to 1900-01-01 and lesser than or equal to #{Date.today.to_s}."
        end

        @sadhak_profiles = SadhakProfile.joins(:address).where('LOWER(first_name) = ? and date_of_birth = ?', params[:first_name].downcase, params[:date_of_birth].to_s)

        if params.has_key?('city_id')
          raise 'City cannot be blank.' unless params[:city_id].present?
          @sadhak_profiles = @sadhak_profiles.where(addresses: {city_id: params[:city_id]})
        end

      rescue Exception => e
        Rails.logger.info("Sadhak Profile: search_syid - Exception: #{e.message}")
        is_error = true
        message = e.message
      end

      if is_error
        custom_error(key: 'sadhak_profile', message: message)
      else
        render json: @sadhak_profiles
      end
    end

    def mini_search_syid
      begin
        raise 'First Name cannot be blank.' unless params[:first_name].present?
        raise 'Date of birth cannot be blank.' unless params[:date_of_birth].present?

        if (Date.parse(params[:date_of_birth].to_s) rescue ArgumentError) == ArgumentError
          raise "Date of birth is not a valid date (#{params[:date_of_birth].to_s})"
        end
        date_of_birth = Date.parse(params[:date_of_birth].to_s)
        unless date_of_birth <= Date.today and date_of_birth >= Date.new(1900,1,1)
          raise "Date of birth should be greater than or equal to 1900-01-01 and lesser than or equal to #{Date.today.to_s}."
        end

        @sadhak_profiles = SadhakProfile.joins(:address).where('LOWER(first_name) = ? and date_of_birth = ?', params[:first_name].downcase, params[:date_of_birth].to_s).order(:id)

        if params.has_key?('city_id')
          raise 'City cannot be blank.' unless params[:city_id].present?
          @sadhak_profiles = @sadhak_profiles.where(addresses: {city_id: params[:city_id]}).order(:id)
        end

      rescue Exception => e
        Rails.logger.info("Sadhak Profile: mini_search_syid - Exception: #{e.message}")
        is_error = true
        message = e.message
      end

      if is_error
        custom_error(key: 'sadhak_profile', message: message)
      else
        render json: @sadhak_profiles.collect{|sp| {syid: sp.syid, first_name: sp.first_name, last_name: sp.last_name}}
      end
    end

    def notify_sadhak_profiles
      if notify_sadhak_params.has_key?("verification_method") and notify_sadhak_params.has_key?("message") and notify_sadhak_params.has_key?("sadhak_profile_ids")
        @message = notify_sadhak_params[:message]
        @sadhak_profile_ids = notify_sadhak_params[:sadhak_profile_ids]
        @verification_method = notify_sadhak_params[:verification_method]
        @sy_club_id = notify_sadhak_params[:sy_club_id]
        errors  = []
        @sadhaks = SadhakProfile.where(id: @sadhak_profile_ids).includes({ address: [:db_city, :db_state, :db_country] }) if @sadhak_profile_ids.present?
        if @sadhaks.count > 0
          case @verification_method
          when 'email'
            mail = UserMailer.notify_sadhaks(@sadhaks, @message, @sy_club_id).deliver
            @errors = mail.present? ? [] : ["Error in sending mail"]
          when 'mobile'
            if @sy_club_id.present?
              sy_club = SyClub.find(@sy_club_id)
              @message = "Notification from Shivyog Club Admin\nClub: " + sy_club.name.capitalize + "\nMessage: " + @message
              @errors = send_notification_message(@sadhaks, @message)
            else
              @message = "Notification from Shivyog Admin\nMessage: " + @message
              @errors = send_notification_message(@sadhaks, @message)
            end
          else
            errorObj= {
            errors:{
              Verification_Method: ["Please select a verification method"]
              }
            }
            render json:  errorObj, status: :unprocessable_entity
            return false
          end
          if !@errors.present?
            successObj= {
              success:{
                Notification_Messsage: ["successfully send"]
                }
              }
            render json:  successObj
          else
            errorObj= {
              errors:{
                sadhak_profile: @errors
                }
              }
            render json:  errorObj, status: :unprocessable_entity
          end
        else
          errorObj= {
          errors:{
            sadhak_profile: ["please select sadhak profiles"]
            }
          }
          render json:  errorObj, status: :unprocessable_entity
        end
      else
        # errors.push("Please fill all the details")
        errorObj= {
          errors:{
            details_missing: ["please fill all the details"]
            }
          }
        render json:  errorObj, status: :unprocessable_entity
      end
    end

    def send_notification_message(sadhaks, message)
      error_messages = []
      sadhaks.each do |sadhak|
        if sadhak.address.present?
          country = sadhak.address.db_country if sadhak.address.country_id.present?
          telephone_prefix = country.telephone_prefix
          country_code =  country.ISO2
          res = SendSms.call(sadhak.mobile.to_s, telephone_prefix, "Namah Shivay," + sadhak.full_name + " with SYID: " + sadhak.syid + "\n" + message, country_code.to_s)
          error_messages.push("Name: #{sadhak.full_name} SYID: #{sadhak.syid} cannot send message...!!") unless res.present?
        else
          error_messages.push("Name: #{sadhak.full_name} SYID: #{sadhak.syid} address missing...!! ")
        end
      end
      error_messages
    end

    def total_shivir_attended

      begin

        sadhak_profile = SadhakProfile.find_by_id(params[:sadhak_profile_id])

        raise 'Sadhak profile not found.' unless sadhak_profile.present?

        attented_events = sadhak_profile.event_registrations.where(event_registrations: {status: EventRegistration.valid_registration_statuses}).includes(:event_order, :event)

      rescue Exception => e

        message = e.message

      end

      if message.present?

        custom_error(key: 'sadhak_profile', message: message)

      else

        render json: attented_events, each_serializer: SadhakShivirAttentedDetailSerializer

      end

    end

    def total_shivir_organised

      begin

        raise "User id cannot be blank." unless params[:user_id].present?

        organized_event_count = Event.where(creator_user_id: params[:user_id]).count

      rescue Exception => e

        message = e.message

      end

      if message.present?

        custom_error(key: 'sadhak_profile', message: message)

      else

        render json: {organized_shivir_count: organized_event_count}

      end

    end

    def upcoming_shivirs
      begin
        @sadhak_profile = SadhakProfile.find(params[:sadhak_profile_id])
        authorize @sadhak_profile
        event_ids = GlobalPreference.where(key: %w(india_clp_events global_clp_events)).collect{|gp| gp.try(:val).to_s.split(',')}.flatten
        @upcoming_events = @sadhak_profile.event_registrations.joins(:event).where('event_registrations.status IN (?) AND events.event_start_date >= ? AND events.id NOT IN (?) AND events.shivir_card_enabled = ?', EventRegistration.valid_registration_statuses, (Date.today - 1.day), event_ids, true).includes(:event, :event_order).order('events.event_end_date')
      rescue Exception => e
        message = e.message
      end
      if message.present?
        render json: {errors: [message]}
      else
        render json: @upcoming_events, each_serializer: SadhakShivirAttentedDetailSerializer
      end
    end

    def locate_collection
      if params.has_key?('filter')
        @qsadhak_profiles = SadhakProfilePolicy::Scope.new(current_user, SadhakProfile).resolve(filtering_params).includes(SadhakProfile.includable_data)
      else
        @qsadhak_profiles = policy_scope(SadhakProfile.preloaded_data)
      end
    end

    def search_sadhaks_pending_approval
      if params.has_key?('sadhak_profile_ids') and params[:sadhak_profile_ids].present?
        sadhaks = SadhakProfile.where(id: params[:sadhak_profile_ids])
      else
        sadhaks = SadhakProfile.where('profile_photo_status IN (0,2) OR photo_id_status IN (0,2) OR address_proof_status IN (0,2)')
      end
      if sadhaks.count > 0
        error = prepare_excel_for_pending_sadhaks(sadhaks)
        if error.present?
          render json: error, status: :unprocessable_entity
        else
          render json: {success: ['Information sent successfully.']}
        end
      else
        render json: {sadhak_profiles: ['No sadhaks profiles found.']}, status: :unprocessable_entity
      end
    end

    def search_syid_using_mobile_or_email
      errors = []
      if params.has_key?('method') and params[:method].present?
        if params[:method] == 'mobile' and params.has_key?('mobile') and params[:mobile].present?
          @sadhaks = SadhakProfile.where(mobile: params[:mobile])
          if @sadhaks.count > 0
            mobile_verification_token = SecureRandom.random_number(1000000)
            session[:mobile_verification_token] = mobile_verification_token
            params[:verification_code] = mobile_verification_token
            message = send_syids
          else
            errors.push('No profile found with this contact number.')
          end
        elsif params[:method] == 'email'
          @sadhaks = SadhakProfile.where(email: params[:email])
          if @sadhaks.count > 0
            email_verification_token = SecureRandom.random_number(1000000)
            session[:email_verification_token] = email_verification_token
            params[:verification_code] = email_verification_token
            message = send_syids
          else
            errors.push('No profile found with this email.')
          end
        else
          errors.push("No valid verification method found.")
        end
        errors.push(message) if message.present?
        if errors.count == 0
          render json: {success: ['Information sent successfully.']}
        else
          errorObj= {errors:{verification_code: errors}}
          render json:  errorObj, status: :unprocessable_entity
        end
      else
        errorObj= {errors:{verification: ["Not found."]}}
        render json:  errorObj, status: :unprocessable_entity
      end
    end

    # Method not in use
    def send_verification_code(verification_method, method_value, sadhak_profiles)
      if verification_method == 'email'
        email_verification_token = SecureRandom.random_number(1000000)
        session[:email_verification_token] = email_verification_token
        email_res = UserMailer.send_syid_list(method_value, email_verification_token, @sadhaks).deliver!
        message = nil
      elsif verification_method == 'mobile'
        mobile_verification_token = SecureRandom.random_number(1000000)
        session[:mobile_verification_token] = mobile_verification_token
        sadhaks_address = sadhak_profiles.last.address
        if sadhaks_address.present?
        country = sadhaks_address.country_id if sadhaks_address.country_id.present?
          message = "List of registered user with this number"
          telephone_prefix = DbCountry.find(country).telephone_prefix
          country_code = DbCountry.find(country).ISO2
          res, message = SendSms.call(method_value, telephone_prefix, "SHIVYOG - Mobile verification code for syid request is: " + session[:mobile_verification_token].to_s, country_code)
        else
          message = ("Name: #{sadhak.full_name} SYID: #{sadhak.syid} address missing...!! ")
        end
      end
      if !message.present?# || email_res
        return true
      else
        errorObj= {
          errors:{
            verification: [message]
            }
          }
        render json:  errorObj, status: :unprocessable_entity
        return false
      end
    end

    def send_syids
      message = nil
      if params.has_key?("verification_code") && params[:verification_code] == session[:mobile_verification_token] and params[:mobile].present?
        sadhaks = SadhakProfile.where(mobile: params[:mobile]).order(:id)
        syids = sadhaks.map{|e| "#{e.syid}-#{e.first_name}"}.join("\n")
        sadhaks.last.delay.send_sms_to_sadhak(syids)
      elsif params.has_key?("verification_code") && params[:verification_code] == session[:email_verification_token]
        @sadhaks = SadhakProfile.where(email: params[:email])
        email_verification_token = nil
        UserMailer.send_syid_list(params[:email], email_verification_token, @sadhaks).deliver!
      else
        message = "Verification code does not match."
      end
      return message
    end

    def generate_file
      begin

        sadhak_profile = SadhakProfile.last

        recipients = (params[:recipients].try(:split, ',').try(:extract_valid_emails).try(:uniq) || [])

        sync = (not recipients.present?)

        # Authorize request
        raise SyException, 'You need to sign in or sign up before continuing.' unless SadhakProfilePolicy.new(current_user, sadhak_profile).generate_file?

        raise SyException, 'SadhakProfile missing for logged in user' unless current_user.sadhak_profile.present?

        if sync
          begin
            search_results = Timeout.timeout(5) do
              SadhakProfilePolicy::Scope.new(current_user, SadhakProfile.includes({ address: [:db_city, :db_state, :db_country] }).order(:id)).resolve(filtering_params).uniq
            end
          rescue Timeout::Error
            raise SyException, 'We are not able to process your request for such large data. Please use email option.'
          end

          raise SyException, 'We are not able to process your request for such large data. Please use email option.' if search_results.size > 1000

          raise SyException, 'No sadhak profile(s) found, Try searching with some other criteria.' unless search_results.present?
        end

        t_config = {file_name: 'sadhak_search_result', prefix: "#{ENV['ENVIRONMENT']}/search_sadhak", template: 'search_sadhak_result', sync: sync}

        task = Task.new(taskable_id: current_user.try(:id), taskable_type: 'User', email: recipients.join(','), opts: filtering_params, t_config: t_config)

        raise SyException, task.errors.full_messages.first unless task.save

        task.add_start_block do |parent_task, params = {}|

          raise ArgumentError.new('Parent task cannot be blank.') unless parent_task.present?

          search_results = SadhakProfilePolicy::Scope.new(parent_task.taskable, SadhakProfile.includes({ address: [:db_city, :db_state, :db_country] }).order(:id)).resolve(params).uniq.pluck(:id)

          raise SyException, 'No sadhak profile found, Try searching with some other criteria.' unless search_results.present?

          parent_task.result = search_results
        end

        task.add_final_block do |sub_task, sadhak_profile_ids, opts = {}|

          raise ArgumentError.new('Sub task cannot be blank.') unless sub_task.present?

          sadhak_profiles = SadhakProfile.where(id: sadhak_profile_ids).includes({ address: [:db_city, :db_state, :db_country] }).order(:id)

          # Generate profiles data.
          data = GenerateSadhakProfilesExcel.call(sadhak_profiles, opts[:status])

          file = GenerateExcel.generate(data.merge({data_type: opts[:sync] ? nil : 'file'}))

          sub_task.result = {file: file, from: sadhak_profiles.first.id, to: sadhak_profiles.last.id, format: 'xls'}
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
          render file: 'customs/success.html.erb', :locals => {title: '', message: "Soon you will get an email on #{recipients.to_sentence}." }
        else
          send_data blob, :filename => "sadhak_search_result_#{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}.xls"
        end
      else
        render file: 'customs/422.html.erb', :locals => {title: 'Sadhak Search Report Download Error.', message: message }
      end
    end

    def banned_sadhak
      begin
        banned_profiles = SadhakProfile.banned

        # raise exception if no profile with status as banned found
      raise SyException, "No banned profile found" unless banned_profiles.present?
        data = GenerateSadhakProfilesExcel.call(banned_profiles, "banned")
        blob = GenerateExcel.generate(data)
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
        send_data blob, :filename => "Banned_Sadhak_List#{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}.xls"
      else
        render json: {error: [message]}, status: :unprocessable_entity
      end

    end

    def generate_card
      begin

        @sadhak_profile = SadhakProfile.find(params[:sadhak_profile_id])

        # authorize @sadhak_profile

        # raise 'You need to sign in or sign up to continue.' unless current_user.present?

        raise 'Please provide registartion refrence number alloted to download entry card.' unless params[:reg_ref_number].present?

        card = @sadhak_profile.generate_shivir_card(params[:reg_ref_number])

      rescue Exception => e
        message = e.message
        is_error = true
      end

      unless is_error
        send_data card, :filename => "#{@sadhak_profile.syid.downcase}_registration_card_event_#{params[:event_id]}_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.pdf"
      else
        render file: 'customs/422.html.erb', :locals => {title: 'Event Entry Card Download Error.', message: message }
      end

    end

    private
    def sadhak_profile_create_params
      params.require(:sadhak_profile).permit(:first_name, :last_name, :middle_name, :gender, :date_of_birth, :mobile, :phone, :email, :occupation_type, :relationship_type, :token, :profile_completeness, :is_approved_for_mega_events,  :is_approved_for_virtual_events, :username, :profile_photo_status, :photo_id_status, :address_proof_status, :is_active, :is_email_verified, :is_mobile_verified, :status, :status_notes, :name_of_guru, :marital_status)
    end

    def sadhak_profile_update_params
      logged_in_sadhak_update_params = {}

      non_logged_sadhak_update_params = params.require(:sadhak_profile).permit(:first_name, :last_name, :middle_name, :gender, :date_of_birth, :mobile, :phone, :email, :occupation_type, :relationship_type, :token, :name_of_guru, :marital_status, :spiritual_org_name)

      if current_user.present? and (current_user.super_admin? or current_user.event_admin? or current_user.club_admin?)
        logged_in_sadhak_update_params = params.require(:sadhak_profile).permit(:profile_photo_status, :photo_id_status, :address_proof_status, :is_active, :status, :status_notes)
      end

      non_logged_sadhak_update_params.merge(logged_in_sadhak_update_params)
    end

    def set_sadhak_profile
      @sadhak_profile = SadhakProfile.find(params[:id])
    end

    def basic_profile_complete?
      return true
    end

    def own_profile_params
      params.require(:sadhak_profile).permit(:syid, :first_name, :ownership_request_token)
    end

    def search_for_order_params
      params.require(:sadhak_profile).permit!#(:syid, :first_name, :ownership_request_token)
    end


    def add_user_params
      params.require(:sadhak_profile).permit(:syid, :first_name, :ownership_request_token)
    end

    def confirm_sadhak_profile_params
      params.require(:sadhak_profile).permit(:syid, :first_name, :verification_code)
    end

    def filtering_params
      params.slice(:syid, :email, :mobile, :first_name, :city_id, :country_id, :state_id, :profession_id, :occupation, :registration_center_id, :creation_from, :creation_to, :status, :sy_club_id, :last_name, :registration_from, :registration_to)
    end

    def notify_sadhak_params
      params.require(:sadhak_profile).permit(:sadhak_profile_ids, :message, :verification_method, sadhak_profile_ids: [])
    end
  end
end
