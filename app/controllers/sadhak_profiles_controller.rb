class SadhakProfilesController < ApplicationController
  include SadhakProfilesHelper

  NON_STORABLE_ACTIONS = %w(created verify_token_create_sadhak_profile resend_sadhak_profile_verification_token)

  before_action :set_sadhak_profile, only: [:show, :edit, :update, :destroy, :profile_photo_approve, :profile_photo_reject, :related_sadhak_profiles, :questionnaire_form]
  before_action :set_event, only: [:event_register_syid_search, :event_register_forgot_syid, :edit_registration_syid_search, :edit_registration_forgot_syid, :questionnaire_form]
  before_action :authenticate_user!, except: [:validate_user_name, :verify_token_create_sadhak_profile, :resend_sadhak_profile_verification_token, :sadhak_profile_token_verification, :new, :event_register_syid_search, :event_register_forgot_syid, :create, :users_for_provider_login, :verify_user_for_provider_login, :created, :verify_token_update_email_and_mobile, :resend_sadhak_profile_verification_token, :edit_registration_syid_search, :edit_registration_forgot_syid, :forgot_syid, :search_syid_by_mobile_or_email, :search_syid_by_details,:questionnaire_form]
  skip_before_action :verify_authenticity_token, only: [:profile_photo_approve, :profile_photo_reject, :approve_selected, :reject_selected, :update_sadhak_profile_photo, :questionnaire_form]
  before_action :set_sadhak_profile_and_authorize, only:[:assign_role_to_sadhak_profile_user, :reset_user_password, :shivir_info, :forum_info, :profile_details, :edit_sadhak_profile_photo, :update_sadhak_profile_photo, :change_sadhak_profile_status, :update_sadhak_profile_status, :sadhak_profile_logs, :role_assignment_to_sadhak_profile_user, :assign_role_to_sadhak_profile_user]

  # GET /sadhak_profiles
  def index
    @sadhak_profiles = SadhakProfile.all
  end

  # GET /sadhak_profiles/1
  def show
     authorize @sadhak_profile
  end

  # GET /sadhak_profiles/new
  def new

    @sadhak_profile = SadhakProfile.new(get_cookie(NEW_SADHAK_PROFILE_COOKIE_KEY))
    unless @sadhak_profile.address.present?
      address = @sadhak_profile.build_address
      address.build_db_country
      address.build_db_state
      address.build_db_city
    end

    # Delete sadhak profile from cookies.
    cookies.delete(NEW_SADHAK_PROFILE_COOKIE_KEY.encrypt)
    cookies.delete(EDIT_SADHAK_PROFILE_ID_COOKIE_KEY.encrypt)

  end

  # POST  /sadhak_profiles/verify_token_create_sadhak_profile
  def verify_token_create_sadhak_profile

    begin
      raise SyException, "Verification token cannot be blank." unless sadhak_profile_token_verification_params[:verification_token].present?
      raise SyException, "No sadhak profile found" unless get_cookie(NEW_SADHAK_PROFILE_COOKIE_KEY).present?
      @sadhak_profile = SadhakProfile.new(get_cookie(NEW_SADHAK_PROFILE_COOKIE_KEY))

      # Mobile vierified.
      @is_mobile_verified = @sadhak_profile.mobile_verification_token.present? && @sadhak_profile.mobile_verification_token.eql?(sadhak_profile_token_verification_params[:verification_token])

      # Email vierified.
      @is_email_verified = @sadhak_profile.email_verification_token.present? && @sadhak_profile.email_verification_token.eql?(sadhak_profile_token_verification_params[:verification_token])
      raise SyException, "Invalid Verification token." unless (@is_email_verified.present? || @is_mobile_verified.present?)

      ActiveRecord::Base.transaction do

        # Save new sadhak profile.
        raise SyException, @sadhak_profile.errors.full_messages.first unless @sadhak_profile.save

        # Update sadhak profile.
        @sadhak_profile.update_attributes(is_email_verified: @is_email_verified, is_mobile_verified: @is_mobile_verified, mobile_verification_token: nil, email_verification_token: nil)

        # Define relation between current_user and new sadhak_profile if sadhak_profile exist.
        Relation.create(user_id: current_user.id, sadhak_profile_id: @sadhak_profile.id, is_verified: true) if current_user.present?

        # Delete sadhak profile from cookies.
        cookies.delete(NEW_SADHAK_PROFILE_COOKIE_KEY.encrypt)
        cookies.delete(EDIT_SADHAK_PROFILE_ID_COOKIE_KEY.encrypt)

        if @is_mobile_verified
          @sadhak_profile.delay.send_sms_to_sadhak("NMS #{@sadhak_profile.full_name}\nYou have successfully created your profile.\nFirst Name: #{@sadhak_profile.first_name}\nSYID: #{@sadhak_profile.syid}")
        end
        if @is_email_verified
          from = GetSenderEmail.call(@sadhak_profile)
          ApplicationMailer.send_email(from: from, subject: "Welcome to Shivyog #{@sadhak_profile.syid}", template: 'welcome', sadhak_profile: @sadhak_profile, recipients: @sadhak_profile.email).deliver_later
        end

      end

    rescue SyException => e
      @message = e.message
    end

    if @message.present?
      flash[:error] = @message
      redirect_back(fallback_location: root_path)
    else
      flash[:success] = "Account has been successfully created. Please generate your password."
      redirect_to created_sadhak_profile_path(@sadhak_profile.slug)
    end

  end

  def verify_token_update_email_and_mobile

    begin

      raise SyException, "Verification token cannot be blank." unless sadhak_profile_token_verification_params[:verification_token].present?
      raise SyException, "No sadhak profile found" unless cookies.encrypted[EDIT_SADHAK_PROFILE_ID_COOKIE_KEY.encrypt].present?
      @sadhak_profile = SadhakProfile.find_by_id(cookies.encrypted[EDIT_SADHAK_PROFILE_ID_COOKIE_KEY.encrypt])
      user = @sadhak_profile.user

      # Initialze variables
      unconfirmed_mobile, unconfirmed_email, @is_mobile_verified, @is_email_verified = user.unconfirmed_mobile, user.unconfirmed_email, @sadhak_profile.is_mobile_verified, @sadhak_profile.is_email_verified

      # Mobile vierified
      @is_mobile_verified = @sadhak_profile.mobile_verification_token.eql? sadhak_profile_token_verification_params[:verification_token]

      # Email verified
      @is_email_verified = @sadhak_profile.email_verification_token.eql? sadhak_profile_token_verification_params[:verification_token]

      raise SyException, "Invalid Verification token." unless @is_email_verified || @is_mobile_verified

      ActiveRecord::Base.transaction do

        data = {
          old_email: @sadhak_profile.email,
          old_mobile: @sadhak_profile.mobile,
          old_is_email_verified: @sadhak_profile.is_email_verified,
          old_is_mobile_verified: @sadhak_profile.is_mobile_verified
        }

        # Update sadhak profile
        @sadhak_profile.update_columns(mobile: (unconfirmed_mobile || @sadhak_profile.mobile), email: (unconfirmed_email || @sadhak_profile.email), is_email_verified: @is_email_verified, is_mobile_verified: @is_mobile_verified, email_verification_token: nil, mobile_verification_token: nil)

        data.merge!({
          new_email: @sadhak_profile.email,
          new_mobile: @sadhak_profile.mobile,
          new_is_email_verified: @sadhak_profile.is_email_verified,
          new_is_mobile_verified: @sadhak_profile.is_mobile_verified
        })

        @sadhak_profile.create_public_activity(data) if current_user && current_user.try(:sadhak_profile) != @sadhak_profile && (current_user.super_admin? || current_user.india_admin?)

        # Update user associated with sadhak profile.
        user.update_columns(email: (@is_email_verified ? (unconfirmed_email || @sadhak_profile.email) : (@sadhak_profile.email || "")), unconfirmed_email: nil, contact_number: (@is_mobile_verified ? (unconfirmed_mobile || @sadhak_profile.mobile) : (@sadhak_profile.mobile || "")), unconfirmed_mobile: nil)

      end

    rescue SyException => e
      @message = e.message
    end

    if @message.present?
      flash[:alert] = @message
      redirect_back(fallback_location: root_path)
    else

      # Delete sadhak profile's id from cookies
      cookies.delete(EDIT_SADHAK_PROFILE_ID_COOKIE_KEY.encrypt)
      cookies.delete(NEW_SADHAK_PROFILE_COOKIE_KEY.encrypt)
      flash[:success] = "Contact info has been successfully updated."
      redirect_to cookies.encrypted[REDIRECT_URL_COOKIE_KEY.encrypt] || root_path
    end

  end


  # GET /sadhak_profiles/1/resend_sadhak_profile_token_verification
  def resend_sadhak_profile_verification_token

    begin

      raise SyException, "No sadhak profile found." unless get_cookie(NEW_SADHAK_PROFILE_COOKIE_KEY).present?
      @sadhak_profile = SadhakProfile.new(get_cookie(NEW_SADHAK_PROFILE_COOKIE_KEY))
      raise SyException, "Coundn't found any mobile number or email with profile."  unless @sadhak_profile.email.present? || @sadhak_profile.mobile.present?

      # Send token and return sadhak profile object with verification token.
      @sadhak_profile = @sadhak_profile.send_verification_token

      # Initialize sadhak_profile_params_with_token.
      sadhak_profile_params_with_token = get_cookie(NEW_SADHAK_PROFILE_COOKIE_KEY)

      # Set mobile verification token and email verification token.
      sadhak_profile_params_with_token[:email_verification_token] = @sadhak_profile.email_verification_token
      sadhak_profile_params_with_token[:mobile_verification_token] = @sadhak_profile.mobile_verification_token

      # Delete stored sadhak_profile.
      cookies.delete(NEW_SADHAK_PROFILE_COOKIE_KEY.encrypt)
      cookies.delete(EDIT_SADHAK_PROFILE_ID_COOKIE_KEY.encrypt)

      # Encrypt and store sadhak_profile.
      set_cookie(NEW_SADHAK_PROFILE_COOKIE_KEY, sadhak_profile_params_with_token.as_json, 10.minutes)

      if @sadhak_profile.mobile.present? && !@sadhak_profile.email.present?
        medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[1]
      elsif @sadhak_profile.email.present? && !@sadhak_profile.mobile.present?
        medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[0]
      else
        medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[2]
      end

      @admin_msg = " and logged in Admin Email" if current_user && current_user.try(:sadhak_profile) != @sadhak_profile && (current_user.super_admin? || current_user.india_admin?)
      @success = "Verification Token has been successfully sent to your #{medium}#{@admin_msg}."

    rescue SyException => e
      @message = e.message
    end

  end


  def resend_edit_sadhak_profile_verification_token

    begin

      raise SyException, "No sadhak profile found." unless cookies.encrypted[EDIT_SADHAK_PROFILE_ID_COOKIE_KEY.encrypt].present?
      @sadhak_profile = SadhakProfile.find_by_id(cookies.encrypted[EDIT_SADHAK_PROFILE_ID_COOKIE_KEY.encrypt])
      user = @sadhak_profile.user
      raise SyException, "No user found associated with sadhak profile." unless user.present?

      # Send token and return sadhak profile object with verification token.
      @sadhak_profile = @sadhak_profile.send_verification_token

      # Save sadhak profile's verification token.
      raise SyException, @sadhak_profile.errors.full_messages.first unless @sadhak_profile.save

      # Set medium
      if (user.unconfirmed_email.present? || @sadhak_profile.email.present?) && !user.unconfirmed_mobile.present?
        medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[0]
      elsif !user.unconfirmed_email.present? && (user.unconfirmed_mobile.present? || @sadhak_profile.mobile.present?)
        medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[1]
      else
        medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[2]
      end

      @success = "Verification Token has been successfully sent to your #{medium}."

    rescue SyException => e
      @message = e.message
    end

  end

  # GET /sadhak_profiles/sadhak_profile_token_verification
  def sadhak_profile_token_verification
    # This action will be called for both existing sadhak profile and new sadhak profile when sadhak profile verification needed.
    begin

      raise SyException, "No sadhak profile found." unless (get_cookie(NEW_SADHAK_PROFILE_COOKIE_KEY).present? || get_cookie(EDIT_SADHAK_PROFILE_ID_COOKIE_KEY).present?)

      # Get Sadhak profile from cookies.
      # If existing sadhak profile.
      # OR If new sadhak profile.
      @sadhak_profile = SadhakProfile.find_by_id(get_cookie(EDIT_SADHAK_PROFILE_ID_COOKIE_KEY)) || SadhakProfile.new(get_cookie(NEW_SADHAK_PROFILE_COOKIE_KEY))

    rescue SyException => e
      @message = e.message
    end

    if @message.present?
      flash[:error] = @message
      redirect_to root_path
    else

      # Check whether request came from existing sadhak profile or new sadhak profile.
      @url = @sadhak_profile.persisted? ? verify_token_update_email_and_mobile_sadhak_profiles_path : verify_token_create_sadhak_profile_sadhak_profiles_path
    end
  end


  # GET /sadhak_profiles/1/edit
  def edit

    authorize @sadhak_profile
    @sp_accordion_id = params[:sp_accordion_id]

    @country = DbCountry.pluck(:name, :id)

    @sadhak_profile.tap do |sadhak|
      sadhak.professional_detail || sadhak.build_professional_detail
      sadhak.doctors_profile || sadhak.build_doctors_profile
      (sadhak.advance_profile || sadhak.build_advance_profile).tap do |ad_profile|
        ad_profile.advance_profile_photograph || ad_profile.build_advance_profile_photograph
        ad_profile.advance_profile_identity_proof || ad_profile.build_advance_profile_identity_proof
        ad_profile.advance_profile_address_proof || ad_profile.build_advance_profile_address_proof
      end
      sadhak.medical_practitioners_profile || sadhak.build_medical_practitioners_profile
      # sadhak.spiritual_journey || sadhak.build_spiritual_journey
      sadhak.sadhak_seva_preference || sadhak.build_sadhak_seva_preference
      # sadhak.spiritual_practice  || sadhak.build_spiritual_practice
    end

    unless @sadhak_profile.address.present?
      address = @sadhak_profile.build_address
      address.build_db_country
      address.build_db_state
      address.build_db_city
    end

    @other_spiritual_associations = params[:other_spiritual_association_id].present? ? @sadhak_profile.other_spiritual_associations - OtherSpiritualAssociation.where(id: params[:other_spiritual_association_id]) : @sadhak_profile.other_spiritual_associations
    @other_spiritual_association = OtherSpiritualAssociation.find_by_id(params[:other_spiritual_association_id]) || OtherSpiritualAssociation.new(sadhak_profile_id: @sadhak_profile.id)

    @sadhak_profile_attended_shivir = SadhakProfileAttendedShivir.find_by_id(params[:sadhak_profile_attended_shivir_id]) || SadhakProfileAttendedShivir.new()
    @sadhak_profile_attended_shivirs = params[:sadhak_profile_attended_shivir_id].present? ? @sadhak_profile.sadhak_profile_attended_shivirs - SadhakProfileAttendedShivir.where(id: params[:sadhak_profile_attended_shivir_id]) : @sadhak_profile.sadhak_profile_attended_shivirs

    begin

      @sadhak_profile.create_aspects_of_life! if @sadhak_profile.aspects_of_life.blank?
      @aspect_feedback = @sadhak_profile.aspects_of_life.aspect_feedbacks

    rescue Exception => e

        logger.info("#Exception in sadhak profile edit action: {e.message}")

    end

    @own_sadhak_profile = current_user.sadhak_profile

  end

  # POST /sadhak_profiles
  def create

    @sadhak_profile = SadhakProfile.new(sadhak_profile_params)

    begin

      set_cookie(NEW_SADHAK_PROFILE_COOKIE_KEY, sadhak_profile_params.to_json, 10.seconds)

      raise SyException, @sadhak_profile.errors.full_messages.first unless @sadhak_profile.valid?

      # Set verification token and return sadhak profile.
      @sadhak_profile = @sadhak_profile.send_verification_token

      # Initialize sadhak_profile_params_with_token.
      sadhak_profile_params_with_token = sadhak_profile_params

      # Set mobile verification token and email verification token.
      sadhak_profile_params_with_token[:email_verification_token] = @sadhak_profile.email_verification_token
      sadhak_profile_params_with_token[:mobile_verification_token] = @sadhak_profile.mobile_verification_token

      # Delete cookies if any exist before store sadhak profile
      cookies.delete(NEW_SADHAK_PROFILE_COOKIE_KEY.encrypt)
      cookies.delete(EDIT_SADHAK_PROFILE_ID_COOKIE_KEY.encrypt)

      # Encrypt and store sadhak_profile.
      set_cookie(NEW_SADHAK_PROFILE_COOKIE_KEY, sadhak_profile_params_with_token.to_json, 10.minutes)
      cookies[RESEND_TIMER_KEY] = { value: RESEND_TIMER, expires: 30.seconds.from_now }

      # Set medium.
      if @sadhak_profile.mobile? && @sadhak_profile.email?
        medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[2]
      elsif @sadhak_profile.email?
        medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[0]
      else
        medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[1]
      end
    rescue SyException => e
      @message = e.message
    end

    if @message.present?
      flash[:error] = @message
      redirect_to new_sadhak_profile_path
    else
      flash[:success] = "Verification code has been successfully sent to your #{medium}."
      redirect_to sadhak_profile_token_verification_sadhak_profiles_path
    end

  end

  # PATCH/PUT /sadhak_profiles/1
  def update
    authorize @sadhak_profile

    begin
      medium, sadhak_profile_verification_needed =  @sadhak_profile.update_or_verify(update_sadhak_profile_params)
    rescue SyException => e
      message = e.message
    end

    unless message.present?
      if sadhak_profile_verification_needed
        # Delete cookies if any exist before store sadhak profile
        cookies.delete(NEW_SADHAK_PROFILE_COOKIE_KEY.encrypt)
        cookies.delete(EDIT_SADHAK_PROFILE_ID_COOKIE_KEY.encrypt)

        # Store sadhak profile id in cookies.
        cookies.encrypted[EDIT_SADHAK_PROFILE_ID_COOKIE_KEY.encrypt] = @sadhak_profile.id
        cookies[RESEND_TIMER_KEY] = { value: RESEND_TIMER, expires: 30.seconds.from_now }
        cookies.encrypted[REDIRECT_URL_COOKIE_KEY.encrypt] = request.referrer

        # If email or mobile also will be update.
        @admin_msg = " and logged in Admin Email" if current_user && current_user.try(:sadhak_profile) != @sadhak_profile && (current_user.super_admin? || current_user.india_admin?)
        flash[:success] = "Verification code has been successfully sent to your #{medium}#{@admin_msg}."
        redirect_to sadhak_profile_token_verification_sadhak_profiles_path(edit_sadhak_profile: true)
      else
        flash[:success] = 'Sadhak profile was successfully updated.'
        redirect_to edit_sadhak_profile_path(params[:id], sp_accordion_id: params[:sadhak_profile][:sp_accordion_id])
      end
    else
      flash[:alert] = message
      redirect_to edit_sadhak_profile_path(params[:id], sp_accordion_id: params[:sadhak_profile][:sp_accordion_id])
    end

  end

  # DELETE /sadhak_profiles/1
  def destroy
  		authorize @sadhak_profile

  		if @sadhak_profile.destroy
  			flash[:success] = 'Sadhak profile was successfully deleted.'
  		else
  			flash[:error] = @sadhak_profile.errors.full_messages.first
  		end
    redirect_back(fallback_location: root_path)
  end

  def event_register_syid_search

    begin
      search_syids_for_register_edit_details
      @questionnaire_form_enabled = GlobalPreference.get_value_of('questionnaire_enabled_events')&.split(',')&.map(&:to_i)&.include?(@event.id)
      if @questionnaire_form_enabled
        @blank_questionnaire_form = EventSadhakQuestionnaire.where(event_id: @event.id, sadhak_profile_id: @sadhak_profile.id).blank?
      end

    rescue Exception => e

      logger.error("SadhakProfile: event_register_syid_search: #{e.message}")
      @message = e.message

    end

    respond_to do |format|
      format.js { render 'event_register_syid_search.js.erb', locals: { action: "syid-search" } }
    end

  end

  def event_register_forgot_syid

    begin

      forgot_syid_for_register_edit_details

    rescue Exception => e

      logger.error("SadhakProfile: event_register_forgot_syid: #{e.message}")
      @message= e.message

    end

    respond_to do |format|
      format.js { render 'event_register_syid_search.js.erb', locals: { action: "forgot-syid" } }
    end

  end

  def edit_registration_syid_search

    begin

      search_syids_for_register_edit_details

      raise "No editable row found." unless params[:sadhak_profiles][:from_syid].present?
      @from_syid = params[:sadhak_profiles][:from_syid]

    rescue Exception => e

      logger.error("SadhakProfile: edit_registration_syid_search: #{e.message}")
      @message = e.message

    end

    respond_to do |format|
      format.js { render 'events/edit_details_syid_search.js.erb' }
    end

  end

  def edit_registration_forgot_syid

    begin

      forgot_syid_for_register_edit_details

      raise "No editable row found." unless params[:sadhak_profile][:from_syid].present?
      @from_syid = params[:sadhak_profile][:from_syid]

    rescue Exception => e

      logger.error("SadhakProfile: edit_registration_forgot_syid: #{e.message}")
      @message= e.message

    end

    respond_to do |format|
      format.js { render 'events/edit_details_syid_search.js.erb' }
    end

  end

  def generate_card
    begin

      @sadhak_profile = SadhakProfile.find(params[:sadhak_profile_id])

      raise 'Please provide registartion refrence number alloted to download entry card.' unless params[:reg_ref_number].present?

      card = @sadhak_profile.generate_shivir_card(params[:reg_ref_number])

    rescue Exception => e
      message = e.message
      is_error = true
    end
    unless is_error
      send_data card, :filename => "#{@sadhak_profile.syid.downcase}_registration_card_event_#{params[:event_id]}_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.pdf"
    else
    	flash[:error] = message
    	redirect_back(fallback_location: root_path)
      # render file: 'customs/422.html.erb', :locals => {title: 'Event Entry Card Download Error.', message: message }
    end

  end

  def profile_photo_approve

    @event = Event.find_by_id(sadhak_profile_params[:event_id])

    raise Pundit::NotAuthorizedError unless SadhakProfilePolicy.new(current_user, @sadhak_profile, @event).profile_photo_approve?

    @sadhak_profile.event_id = @event.try(:id)

    @sadhak_profile.pp_approve && @sadhak_profile.pi_approve && @sadhak_profile.save

    # @sadhak_profile.update(profile_photo_status: SadhakProfile.profile_photo_statuses.pp_success, photo_id_status: SadhakProfile.photo_id_statuses.pi_success)

    respond_to do |format|
      format.js { render 'photo_approval.js.erb' }
    end

  end

  def profile_photo_reject

     @event = Event.find_by_id(sadhak_profile_params[:event_id])

    raise Pundit::NotAuthorizedError unless SadhakProfilePolicy.new(current_user, @sadhak_profile, @event).profile_photo_reject?

    @sadhak_profile.event_id = @event.try(:id)

    @sadhak_profile.status_notes = sadhak_profile_params[:status_notes]

    @sadhak_profile.errors.add(:please, 'select a valid reason of rejection.') unless sadhak_profile_params[:status_notes].present?

    @sadhak_profile.pp_reject && @sadhak_profile.pi_reject && @sadhak_profile.save

    # @sadhak_profile.update(profile_photo_status: SadhakProfile.profile_photo_statuses.pp_rejected, photo_id_status: SadhakProfile.photo_id_statuses.pi_rejected, status_notes: sadhak_profile_params[:status_notes])

    respond_to do |format|
      format.js { render 'photo_approval.js.erb' }
    end

  end

  def approve_selected

    @event = Event.find_by_id(approve_selected_params[:event_id])

    raise Pundit::NotAuthorizedError unless SadhakProfilePolicy.new(current_user, nil, @event).approve_selected?

    @sadhak_profiles = SadhakProfile.where(id: approve_selected_params[:sadhak_profile_ids])

    begin

      raise 'Please select some profiles.' if @sadhak_profiles.size == 0

      ActiveRecord::Base.transaction do
        @sadhak_profiles.each do |sadhak_profile|

          sadhak_profile.event_id = @event.try(:id)

          raise sadhak_profile.errors.full_messages.first unless sadhak_profile.pp_approve && sadhak_profile.pi_approve && sadhak_profile.save

          # raise sadhak_profile.errors.full_messages.first unless sadhak_profile.update(profile_photo_status: SadhakProfile.profile_photo_statuses.pp_success, photo_id_status: SadhakProfile.photo_id_statuses.pi_success)
        end
      end

    rescue Exception => e

      message = e.message
      logger.error(e.message)
      logger.error(e.backtrace)
    end

    message.present? ? flash[:alert] = message : flash[:success] = "Information Saved successfully."

    redirect_back(fallback_location: proc { root_path })

  end

  def reject_selected


    @event = Event.find_by_id(reject_selected_params[:event_id])

    raise Pundit::NotAuthorizedError unless SadhakProfilePolicy.new(current_user, nil, @event).reject_selected?

    @sadhak_profiles = SadhakProfile.where(id: reject_selected_params[:sadhak_profile_ids])

    begin

      raise 'Please select some profiles.' if @sadhak_profiles.size == 0

      raise 'Please select a valid reason of rejection' unless reject_selected_params[:status_notes].present?

      ActiveRecord::Base.transaction do
        @sadhak_profiles.each do |sadhak_profile|

          sadhak_profile.event_id = @event.try(:id)

          sadhak_profile.status_notes = reject_selected_params[:status_notes]

          raise sadhak_profile.errors.full_messages.first unless sadhak_profile.pp_reject && sadhak_profile.pi_reject && sadhak_profile.save

          # raise sadhak_profile.errors.full_messages.first unless sadhak_profile.update(profile_photo_status: SadhakProfile.profile_photo_statuses.pp_rejected, photo_id_status: SadhakProfile.photo_id_statuses.pi_rejected, status_notes: reject_selected_params[:status_notes])

        end
      end

    rescue Exception => e
      message = e.message
      logger.error(e.message)
      logger.error(e.backtrace)
    end

    message.present? ? flash[:alert] = message : flash[:success] = "Information Saved Successfully."

    redirect_back(fallback_location: proc { root_path })

  end

  def users_for_provider_login

    begin

      raise 'SYID(s) not found.' unless params[OAUTH_PARAM_SYIDS.encrypt].present?

      @email = SadhakProfile.find_by_syid(params[OAUTH_PARAM_SYIDS.encrypt].decrypt.split('-').last).try(:email)

    rescue Exception => e

      flash[:alert] = e.message

      redirect_to new_user_session_path

    end

  end

  def verify_user_for_provider_login

    begin

      raise SyException, "Please input a valid sadhak profile asscoiated with #{email}." unless verify_user_for_provider_login_params[:syid].present?

      raise 'Sadhak Profile Ids not found.' unless verify_user_for_provider_login_params[OAUTH_PARAM_SYIDS.encrypt].present?

      raise "Provider Date not found." unless cookies[OAUTH_DATA.encrypt].present?

      oauth_data = JSON.parse(cookies[OAUTH_DATA.encrypt].decrypt.decompress).with_indifferent_access

      syids = verify_user_for_provider_login_params[OAUTH_PARAM_SYIDS.encrypt].decrypt.split('-')

      email = SadhakProfile.find_by_syid(syids.last).try(:email)

      syid = "SY#{verify_user_for_provider_login_params[:syid].strip[/-?\d+/].to_i}"

      raise SyException, "SYID #{syid} is not associated with email: #{email}. Please input valid SYID." unless syids.include?(syid)

      sadhak_profile = SadhakProfile.find_by_syid(syid)

      user = sadhak_profile.user

      raise SyException, "User not found for SYID: #{sadhak_profile.syid}. Please contact Ashram." unless user.present?

      formatted_data = "Oauth::#{Authorization::SOCIAL_PROVIDERS[oauth_data[:provider]][:provider_name]}".constantize.new(oauth_data).formatted_provider_data

      user.authorizations.build(formatted_data.slice(:provider, :uid, :token, :email).merge({ raw_data: oauth_data })).save!

      sign_in user, event: :authentication

      redirect_to root_path

    rescue SyException => e

      flash[:alert] = e.message

      redirect_to users_for_provider_login_sadhak_profiles_path("#{OAUTH_PARAM_SYIDS.encrypt}" => verify_user_for_provider_login_params[OAUTH_PARAM_SYIDS.encrypt])

    rescue Exception => e

      flash[:alert] = e.message

      redirect_to new_user_session_path

    end

  end

  def capture_picture

    authorize :sadhak_profile

  end

  def verify_picture
    @message = {}

    begin
      raise SyException, "Somthing went wrong, Please try again." unless params[:cam][:captured_snapshot].present?
      uri = URI.parse(ENV['GOOGLE_VISION_API_URL'] + "?key=" + ENV['GOOGLE_VISION_API_KEY'])
      header = {'Content-Type': 'text/json'}
      user={
            "requests": [
              {
                "image": {
                  "content": params[:cam][:captured_snapshot].split(',', 2).last
                },
                "features": [
                  {
                    "type": "FACE_DETECTION"
                  }, {
                    "type": "CROP_HINTS"
                  }],"imageContext": {
                    "cropHintsParams":{
                      "aspectRatios": []
                    }
                  }
              }
            ]
          }

      # Create the HTTP objects
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = user.to_json
      http.use_ssl = true
      response = http.request(request)


      raise SyException, "Somthing went wrong, Please try again." unless response.present?

      # Code to get faces cordinates
      response = (ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(response.body)) || {})[:responses]
      faces_data = (((response || []).first || {})[:faceAnnotations] || []).collect{|fa| (fa[:boundingPoly] || {})[:vertices] }

      faces = []

      raise SyException, "No Face found. Please try again..!" unless faces_data.present?
      faces_data.each do |fd|
       face = {}
       face[:img_x] = fd.first[:x]
       face[:img_y] = fd.first[:y]
       face[:img_width] = (fd.first[:x] - fd.second[:x]).abs
       face[:img_height] = (fd.first[:y] - fd.third[:y]).abs
       faces.push(face)
      end


      # Get Magick Image object of captured Image
      img = Magick::Image.read_inline(params[:cam][:captured_snapshot].split(',', 2).last).first

      # Code to crop faces from captured Image
      @face_images = []
      base64_cropped_img = ""

      raise SyException, "No Face found. Please try again..!" unless faces.present?

      faces.each do |fc|
        base64_cropped_img = img.crop(fc.img_x,fc.img_y,fc.img_width,fc.img_height)
        base64_string = Base64.encode64(base64_cropped_img.to_blob)
        base64_string  = base64_string.gsub("\n", '')
        @face_images.push('data:image/png;base64,'+ base64_string)
      end

      raise SyException, "No Face found. Please try again..!" unless @face_images.present?

      # Working Code to store file
      # tmp_file_name = "#{Rails.root}/tmp/#{Random.new_seed.to_s}.png"
      # base64_cropped_img.write(tmp_file_name)
      # @base64_string = Base64.encode64(File.open("#{tmp_file_name}", "rb").read)
    rescue SyException => e
      @message[:error] = e.message
    end

    if faces_data.present? && response.present? && @face_images.present?
     @message[:success] = faces_data.size.to_s + ' Face found.'
    end
    respond_to do |format|
      format.js { render 'verify_picture' }
    end
    # redirect_to action: "capture_picture"
  end

  def search_for_rc_user

    @sadhak = search_syid(syid: params[:rc_user][:syid], first_name: params[:rc_user][:first_name]) if params[:rc_user].present?

    respond_to do |format|
      format.js
    end
  end

  def related_sadhak_profiles

    authorize @sadhak_profile
    sadhak_profile_ids = [@sadhak_profile.id] + current_user.sadhak_profiles.ids
    @related_sadhak_profiles = SadhakProfile.where("id IN (?)", sadhak_profile_ids).order(:id).includes(:advance_profile).page(params[:page]).per(params[:per_page])

  end

  def validate_user_name

    result = SadhakProfile.where("username ILIKE ?", params[:sadhak_profile][:username]).exists? ? "This username already taken." : "true"
    respond_to do |format|
      format.json { render :json => result.to_json }
    end

  end

  def created

    begin
      @sadhak_profile = SadhakProfile.find_by_slug(params[:id])
      raise SyException, 'No Sadhak Profile found.' unless request.referrer.present? &&  @sadhak_profile.present?
      url = Rails.application.routes.recognize_path(request.referrer)
      last_controller = url[:controller]
      last_action = url[:action]
      raise SyException, 'No Sadhak Profile found.'  unless last_controller.eql?('sadhak_profiles') && last_action.eql?("sadhak_profile_token_verification")

    rescue SyException => e
      flash[:alert] = e.message
      redirect_to root_path
    end

  end

  def new_message
    authorize current_sadhak_profile
    @data_sender_type = params[:data_sender_type]
  end

  def send_message
    begin

      sadhak_profiles = SadhakProfile.where(id: params[:sadhak_profile_ids].split(',').uniq)
      raise SyException, "No sadhak profile found." unless sadhak_profiles.present?
      medium = params[:medium].to_i
      mediums = MEDIUM_TO_SEND_VERIFICATION_TOKEN.invert
      raise SyException, "Select one medium to send medium." unless medium.present?

      if medium.eql? mediums['email']
      # Mail
        raise SyException, "No email found to send message" unless sadhak_profiles.first.email.present? if params[:id].present?
        sadhak_profiles.each do |sadhak|
          UserMailer.notify_sadhak(sadhak, params[:email_content]).deliver_later if sadhak.email.present?
        end

        @success = "Message has been successfully sent to sadhak profile."

      elsif medium.eql? mediums['mobile']
      # Sms
        raise SyException, "No mobile number found to send message" unless sadhak_profiles.first.mobile.present? if params[:id].present?
        @message = "Notification from Shivyog Admin \nMessage: " + params[:mob_sms]
        sadhak_profiles.each do |sadhak|
          sadhak.delay.send_sms_to_sadhak(@message)
        end
        @success = "Message has been successfully sent to sadhak profile."

      else
       raise SyException, "Select one medium to send sadhak profile."

      end

    rescue SyException => e
      @error = e.message
    end
  end

  def reset_user_password

  end

  def reset_and_send_user_password

    authorize current_sadhak_profile

    begin

      sadhak_profile = SadhakProfile.friendly.find(params[:id])

      user = sadhak_profile.try(:user)

      raise 'No Sadhak Profile found.' unless sadhak_profile.present?
      raise 'No User found.' unless user.present?

      password = Devise.friendly_token.first(RANDOM_PASSWORD_LENGTH).to_s
      user.password = password
      user.save!

      raise 'No email / mobile found to send password.' unless sadhak_profile.email.present? || sadhak_profile.mobile.present?

      sadhak_profile.send_sms_to_sadhak("NMS #{sadhak_profile.syid}-#{sadhak_profile.full_name}\nYour password has been successfully reset by Admin.\nYour password is: #{password}\nYou can use your username or syid for login.") if sadhak_profile.mobile.present?

      UserMailer.reset_password_notification(sadhak_profile: sadhak_profile, password: password).deliver_now if sadhak_profile.email.present? || user.email.present?
      data = {
        action: "reset_and_send_user_password",
        response: "Password has been successfully reset and send to sadhak profile's email / mobile.",
        whodunit: current_sadhak_profile.syid,
        requester: sadhak_profile.syid,
        is_send_by_email: sadhak_profile.email.present? || user.email.present?,
        is_send_by_mobile: sadhak_profile.mobile.present?
      }
      current_sadhak_profile.create_public_activity(data)
    rescue Exception => e
      @message = e.message
    end

    unless @message.present?
     @success = "Password has been successfully reset and send to sadhak profile's email / mobile."
    end

  end

  def shivir_info
    @attented_events = @sadhak_profile.event_registrations.where(event_registrations: {status: EventRegistration.valid_registration_statuses}).includes(:event_order, :event, user: [:sadhak_profile])
    @organized_event_count = @sadhak_profile.try(:user_id).present? ? Event.where(creator_user_id: @sadhak_profile.user_id).count : 0
  end

  def forum_info

  end

  def profile_details

  end

  def edit_sadhak_profile_photo
    @advance_profile = @sadhak_profile.advance_profile || @sadhak_profile.build_advance_profile
    @advance_profile.build_advance_profile_photograph unless @advance_profile.advance_profile_photograph.present?
    @advance_profile.build_advance_profile_identity_proof unless @advance_profile.advance_profile_identity_proof.present?
    @advance_profile.build_advance_profile_address_proof unless @advance_profile.advance_profile_address_proof.present?
  end

  def update_sadhak_profile_photo
    if @sadhak_profile.update(update_sadhak_profile_photo_params)
      @success = "Sadhak Profile has been successfully updated. "
    else
      @error = @sadhak_profile.errors.full_messages.first
    end

    respond_to  do |format|
      format.js
    end
  end

  def change_sadhak_profile_status

  end

  def update_sadhak_profile_status
    if @sadhak_profile.update(update_sadhak_profile_status_params)
      @success = "Sadhak Profile has been successfully updated. "
    else
      @error = @sadhak_profile.errors.full_messages.first
    end

    respond_to  do |format|
      format.js
    end
  end

  def sadhak_profile_logs
    @sadhak_profile_logs = @sadhak_profile.shivyog_change_logs.includes(creator: [:sadhak_profile]).attribute_name("status")
  end

  def role_assignment_to_sadhak_profile_user

  end

  def assign_role_to_sadhak_profile_user
    assign_role_to_sadhak_profile_user_params = {}
    User::USER_ROLES.each do |role|
      assign_role_to_sadhak_profile_user_params[role] = (params[:user_roles] || []).try(:include?, role)
    end
    user =  @sadhak_profile.user

    if user.update(assign_role_to_sadhak_profile_user_params)
      @success = "Sadhak Profile's roles has been successfully updated. "
    else
      @error = user.errors.full_messages.first
    end

    respond_to  do |format|
      format.js
    end
  end

  def generate_file
    begin

      sadhak_profile = SadhakProfile.last

      recipients = (params[:recipients].try(:split, ',').try(:extract_valid_emails).try(:uniq) || [])

      raise "Please provide valid emails." if params[:recipients].present? && !recipients.present?

      sync = (not recipients.present?)

      # Authorize request
      raise SyException, 'You need to sign in or sign up before continuing.' unless SadhakProfilePolicy.new(current_user, sadhak_profile).generate_file?

      raise SyException, 'SadhakProfile missing for logged in user' unless current_sadhak_profile.present?

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

        file = GenerateExcel.generate(data.merge({data_type: opts[:sync] ? nil : "file"}))

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
        flash[:success] = "Soon you will receive an email on #{recipients.to_sentence}."
        redirect_back(fallback_location: root_path)
      else
        send_data blob, :filename => "sadhak_search_result_#{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}.xls"
      end
    else
    	flash[:error] =  message
      redirect_back(fallback_location: root_path)
    end
  end

  def forgot_syid
    # Render forgot_syid html
  end

  def search_syid_by_mobile_or_email
    begin
      if (params[:medium].eql?(MEDIUM_TO_SEND_VERIFICATION_TOKEN[0]) && params[:email].present?)
        @sadhak_profiles = SadhakProfile.where(email: params[:email], is_email_verified: true).order(:id)
      elsif (params[:medium].eql?(MEDIUM_TO_SEND_VERIFICATION_TOKEN[1]) && params[:mobile].present?)
        @sadhak_profiles = SadhakProfile.where(mobile: params[:mobile], is_mobile_verified: true).order(:id)
      else
        @sadhak_profiles = []
      end
      raise SyException, "No record Found" unless @sadhak_profiles.present?

      syids = @sadhak_profiles.map{|e| "#{e.syid}-#{e.first_name}"}.join("\n")

      @sadhak_profiles.last.delay.send_sms_to_sadhak(syids) if params[:medium].eql? MEDIUM_TO_SEND_VERIFICATION_TOKEN[1]
      email_verification_token = nil
      UserMailer.send_syid_list(params[:email], email_verification_token, @sadhak_profiles).deliver! if params[:medium].eql? MEDIUM_TO_SEND_VERIFICATION_TOKEN[0]
      @success = "SYID list has been sent to you. Please check your #{params[:medium].titleize}."
      flash.now[:success] = @success
    rescue SyException => e
      @error = e.message
      flash.now[:error] = @error
    end
    render 'forgot_syid'
  end

  def search_syid_by_details
    begin
      @states = DbState.country_id(params[:country_id])
      @cities = DbCity.state_id(params[:state_id])
      @sadhak_profiles = SadhakProfile.filter(params.slice(:first_name, :last_name, :date_of_birth, :country_id, :state_id, :city_id).select!{ |k,v| v.present? })
      raise "No Sadhak profile found." unless @sadhak_profiles.present?
      raise "Multiple Sadhak profiles found. Please do more precise search." if @sadhak_profiles.count > 1
      @sadhak_profile = @sadhak_profiles.last
      flash.now[:success] = "Please check details given below. </br> Your Sadhak Profile is - </br> SYID: #{@sadhak_profile.syid}, First name: #{@sadhak_profile.first_name}."
    rescue Exception => e
      @error = e.message
      flash.now[:error] = @error
    end
    render 'forgot_syid'
  end

  def questionnaire_form
    begin
      data = params.require(:questionnaire_form)
      raise "All fields must be field." if data.values.any? &:empty?
      # data.each do |k, v|
      #   raise "#{k} cannot be blank." if v.empty?
      # end
      event_sadhak_questionnaire = EventSadhakQuestionnaire.new(event_id: @event.id, sadhak_profile_id: @sadhak_profile.id, data: data, key: 'EventSadhakQuestionnaire')
      if event_sadhak_questionnaire.save
        @success = "Information has been saved."
      else
        raise event_sadhak_questionnaire.errors.full_messages.first
      end
    rescue Exception => e
      @error = e.message
    end
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def set_sadhak_profile_and_authorize
      @sadhak_profile = SadhakProfile.friendly.find(params[:id])
      authorize current_sadhak_profile
    end

    def set_sadhak_profile
      @sadhak_profile = SadhakProfile.find(params[:id])
    end

    def set_event
      @event = Event.find(params[:event_id])
    end

    # Only allow a trusted parameter "white list" through.
    def update_sadhak_profile_photo_params
      params.require(:sadhak_profile).permit(advance_profile_attributes:[:id, :faith, :any_legal_proceeding, :attended_any_shivir, :photo_id_proof_type_id, :address_proof_type_id, :photo_id_proof_number ,advance_profile_photograph_attributes:[:id, :name, :name_cache], advance_profile_identity_proof_attributes:[:id, :name, :name_cache], advance_profile_address_proof_attributes:[:id, :name, :name_cache]])
    end

    def update_sadhak_profile_status_params
      params.require(:sadhak_profile).permit(:status, :status_notes)
    end

    def assign_role_to_sadhak_profile_user_params
      params.require(:user).permit(:user_roles)
    end

    def sadhak_profile_params
      params.require(:sadhak_profile).permit(:name_of_guru, :spiritual_org_name, :status_notes, :event_id,
       :id, :username, :first_name, :last_name,:date_of_birth, :gender, :mobile, :email,
        address_attributes:[:id, :first_line, :second_line, :country_id , :state_id, :other_state, :city_id, :other_city, :postal_code],
         professional_detail_attributes:[:id, :highest_degree, :profession_id, :designation, :occupation, :name_of_organization, :professional_specialization, :personal_interests, :years_of_experience],
          doctors_profile_attributes: [:medical_school, :education_country_id, :year_of_graduation, :area_of_speciality, :sub_speciality, :license_status, :license_state_id, :license_country_id, :primary_work_setting, :practice_place, :practice_state_id, :practice_country_id, :practice_years, :clinical_research, :hospital_affiliations, :professional_publications, :honors_and_awards, :sadhak_profile_id],
           spiritual_practice_attributes:[:id, :morning_sadha_duration_hours, :afternoon_sadha_duration_hours, :evening_sadha_duration_hours, :other_sadha_duration_hours, :sadhana_frequency_days_per_week, :frequency_period, frequent_sadhna_type_ids:[], physical_exercise_type_ids:[], shivyog_teaching_ids:[]],
            advance_profile_attributes:[:id, :faith, :any_legal_proceeding, :attended_any_shivir, :photo_id_proof_type_id, :address_proof_type_id, :photo_id_proof_number,
             advance_profile_photograph_attributes:[:id, :name, :image_data_base64],
              advance_profile_identity_proof_attributes:[:id, :name],
               advance_profile_address_proof_attributes:[:id, :name]],
                medical_practitioners_profile_attributes:[:id, :current_professional_role,
                 :interested_in_panel_discussion, :interested_in_volunteering, :medical_degree,
                  :medical_practitioner_speciality_area_id, :other_role, :other_speciality,
                   :practiced_integrative_health_care, :sadhak_profile_id, :work_enviroment],
                    sadhak_seva_preference_attributes:[:id, :voluntary_organisation, :availability, :seva_preference, :expertise],
                     spiritual_journey_attributes:[:id, :source_info_type_id, :sub_source_type_id, :first_event_attended, :first_event_attended_year, :first_event_attended_month, :reason_for_joining])

    end

    def update_sadhak_profile_params
      sadhak_profile_params.except(:username)
    end

    def sadhak_profile_token_verification_params
      params.require(:sadhak_profile).permit(:id, :verification_token)
    end

    def search_for_order_params
      params.require(:sadhak_profile).permit(:syid, :date_of_birth, :mobile, :rc_event_id, :first_name)
    end

    def approve_selected_params
      params.require(:sadhak_profile).permit(:sadhak_profile_ids, :event_id, sadhak_profile_ids: [])
    end

    def reject_selected_params
      params.require(:sadhak_profile).permit(:sadhak_profile_ids, :event_id, :status_notes, sadhak_profile_ids: [])
    end

    def search_syid(options = {})

      begin

        raise 'No search params found.' unless options.present?

        syid = "sy#{options[:syid][/-?\d+/].to_i}".upcase
        first_name = options[:first_name].to_s.strip.downcase
        mobile = options[:mobile].to_s.strip
        date_of_birth = Date.parse(options[:date_of_birth]) if options[:date_of_birth].present?
        sadhak_profile = SadhakProfile.where('syid = ? AND (LOWER(first_name) = ? OR mobile = ? OR date_of_birth = ?)', syid, first_name, mobile, date_of_birth).first

        sadhak_profile ||= SadhakProfile.find_by_syid(syid) if current_user.try(:rc?, @event)

      rescue Exception => e

        logger.debug(e.message)

      end

      sadhak_profile

    end

    def verify_user_for_provider_login_params
      params.require(:syid_for_provider_login).permit(:syid, OAUTH_PARAM_SYIDS.encrypt.to_sym)
    end

    def filtering_params
      params.slice(:syid, :email, :mobile, :first_name, :city_id, :country_id, :state_id, :profession_id, :occupation, :registration_center_id, :creation_from, :creation_to, :status, :sy_club_id, :last_name, :registration_from, :registration_to)
    end

    def search_syids_for_register_edit_details

      @sadhak_profile = search_syid(params[:sadhak_profiles].slice(:syid, :first_name, :date_of_birth, :mobile).merge({rc_event_id: params[:event_id]}))

      #raise exception if no sadhak profile found after search.
      raise "No Sadhak Profile found." unless @sadhak_profile.present?

      #check if searched sadhak is valid to register in the event.
      @sadhak_profile.verify_registration_for_event(@event)

      #check sadhak has special other info if the event is Ashram residential shivir
      @has_other_info = SpecialEventSadhakProfileOtherInfo.exists?(sadhak_profile_id: @sadhak_profile.try(:id), event_id: @event.try(:id), event_order_line_item_id: nil) if @event.is_ashram_residential_shivir?

    end

    def forgot_syid_for_register_edit_details

      sadhak_profiles = SadhakProfile.filter(params[:sadhak_profile].slice(:first_name, :last_name, :date_of_birth, :country_id, :state_id, :city_id).select!{ |k,v| v.present? })

      raise "No Sadhak profile found." if sadhak_profiles.count.zero?

      raise "Multiple Sadhak profiles found. Please do more precise search." if sadhak_profiles.count > 1

      sadhak = sadhak_profiles.last

      @sadhak_profile = search_syid({ syid: sadhak[:syid], first_name: sadhak[:first_name], date_of_birth: sadhak[:date_of_birth].to_s }.merge({rc_event_id: params[:event_id]}))

      #raise exception if no sadhak profile found after search.
      raise "No Sadhak Profile found." unless @sadhak_profile.present?

      #check if searched sadhak is valid to register in the event.
      @sadhak_profile.verify_registration_for_event(@event)

      #check sadhak has special other info if the event is Ashram residential shivir
      @has_other_info = SpecialEventSadhakProfileOtherInfo.exists?(sadhak_profile_id: @sadhak_profile.try(:id), event_id: @event.try(:id), event_order_line_item_id: nil) if @event.is_ashram_residential_shivir?

    end

end
