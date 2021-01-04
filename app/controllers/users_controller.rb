class UsersController < ApplicationController
  layout "devise", only: [:forgot_password, :user_confirm_verification_code]

  NON_STORABLE_ACTIONS = %w(verify_verification_code_and_reset_password request_reset_password user_confirm_verification_code verify_verification_code_and_reset_password resend_user_verification_code)

  append_before_action :assert_reset_token_passed, only: :user_confirm_verification_code

  before_action :authenticate_user!, only: [:edit, :update_password]


  def request_reset_password

    begin

      verification_code = rand.to_s[2..7]
      cookies[RESEND_TIMER_KEY] = { value: RESEND_TIMER, expires: RESEND_TIMER.seconds.from_now }
      if user_reset_password_params.has_key?("syid") and user_reset_password_params[:syid].present?
        query = user_reset_password_params[:syid]
        first_name = user_reset_password_params[:first_name]
        @sadhak_profile = FindSadhakProfile.by_query_and_first_name query, first_name
        raise SyException, "No sadhak profile found. Please input a valid combination." unless @sadhak_profile.present?

        @user = @sadhak_profile.user

        raise SyException, "Sadhak profile found but no user associated with sadhak. Please contact Asharam." unless @user.present?
        raise SyException, "NMS #{@sadhak_profile.full_name}, You are not allowed to reset password. Please contact Ashram." if @sadhak_profile.banned?
        user_updated = @user.update_attribute("verification_code", verification_code)
        raise SyException, "Something went wrong while updating verification code in database. Please try again." unless user_updated

        # If none of them selected.
        raise SyException, "Not a valid medium to notify sadhak. Please input a valid input method (Email or Mobile)." unless user_reset_password_params[:medium].present?

        is_email_present = @sadhak_profile.email.present?
        is_email_verified = @sadhak_profile.is_email_verified?
        is_mobile_present = @sadhak_profile.mobile.present?
        is_mobile_verified = @sadhak_profile.is_mobile_verified?

        # If both medium are selected
        if user_reset_password_params[:medium] == MEDIUM_TO_SEND_VERIFICATION_TOKEN.slice(0, 1).values

          # To send on email, email should be present and verified.
          if is_email_present and is_email_verified
            res = UserMailer.user_email_confirmation_notice(@sadhak_profile.email, verification_code, @sadhak_profile).deliver_now
            raise SyException, "There is some error occured while sending email. Please try again." if !res
            medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[0] if res
            email = @sadhak_profile.email

          # To send on mobile, mobile should be present and verified.
          elsif is_mobile_present and is_mobile_verified
            @sadhak_profile.send_sms_to_sadhak("Namah Shivay #{@sadhak_profile.try(:full_name)} Ji,\nYour mobile verification code is " + verification_code.to_s)
            medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[1]
            mobile = @sadhak_profile.mobile

          # If none of them verified, send to send code on email if user email || sadhak email present.
          elsif @user.email.present? || is_email_present
            res = UserMailer.user_email_confirmation_notice(@sadhak_profile.email || @sadhak_profile.user.email, verification_code, @sadhak_profile).deliver_now
            raise SyException, "There is some error occured while sending email. Please try again." if !res
            medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[0] if res
            email = @sadhak_profile.email || @sadhak_profile.user.email
          # If none of them verified, send to send code on email if user email || sadhak email present.
          elsif @user.mobile.present? || is_mobile_present
            @sadhak_profile.send_sms_to_sadhak("Namah Shivay #{@sadhak_profile.try(:full_name)} Ji,\nYour mobile verification code is " + verification_code.to_s)
            medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[1]
            mobile = @sadhak_profile.mobile || @sadhak_profile.user.mobile

          # If there is no email or mobile, verification code cannot send. Contact to Asharam.
          else
            raise SyException, "There is no medium (Email or Mobile) to send verification code. Please contact to Asharam."
          end

        # If email option selected, should be present.
        elsif user_reset_password_params[:medium].include? 'email'
          raise SyException, "No email present. Please update email." unless is_email_present
          # raise SyException, "No verified email present. Please input a verified input method (Email or Mobile) to send verification code." unless is_email_verified
          res = UserMailer.user_email_confirmation_notice(@sadhak_profile.email, verification_code, @sadhak_profile).deliver_now
          raise SyException, "There is some error occured while sending email. Please try again." if !res
          medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[0]
          email = @sadhak_profile.email

        # If mobile option selected, should be present.
        elsif user_reset_password_params[:medium].include? 'mobile'
          is_mobile_present = @sadhak_profile.mobile.present?
          raise SyException, "No mobile number present. Please update mobile number." unless is_mobile_present
          # raise SyException, "No Verified mobile number present. Please input a verified input method (Email or Mobile) to send verification code." unless is_mobile_verified
          @sadhak_profile.send_sms_to_sadhak("Namah Shivay #{@sadhak_profile.try(:full_name)} Ji,\nYour mobile verification code is " + verification_code.to_s)
          medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[1]
          mobile = @sadhak_profile.mobile

        end

      else
        raise SyException, "Please input a valid SYID."
      end

      # Encript key
      user_request_reset_password = { medium: medium, user_id: @sadhak_profile.user_id, mobile: mobile, email: email }
      cookies.encrypted[USER_ID_COOKIE_KEY.encrypt] = { value: user_request_reset_password, expires: 1.hour.from_now }
      # cookies.encrypted[USER_ID_COOKIE_KEY.encrypt] = { value: @user.id, expires: 1.hour.from_now }
    rescue SyException => e

      message = e.message

      logger.info("Manual exception: #{message}")

    end
    if message.nil?
      res = send_verification_code_to_admin_if_admin_logged_in(verification_code, @sadhak_profile)

      message, user_request_reset_password, @text = res if res.present?
      flash[:success] = "Verification code has been successfully sent to your #{medium}."

      @token = @user.update_reset_password_token

      redirect_to user_confirm_verification_code_users_path(reset_password_token: @token)

    else

      flash[:alert] = message

      redirect_back(fallback_location: root_path)

    end

  end


  def user_confirm_verification_code

    begin

      user_request_reset_password_cookie = cookies.encrypted[USER_ID_COOKIE_KEY.encrypt]

      raise SyException, "Verification code has been expired. Please try again." unless user_request_reset_password_cookie.present?

      @user =  User.find_by_id(user_request_reset_password_cookie['user_id'])

      raise SyException, "User not found." unless @user.present?

      @user.reset_password_token = params[:reset_password_token]

      @text = encrypted_email(user_request_reset_password_cookie['email']) if user_request_reset_password_cookie['medium'] == 'email'

      @text = encrypted_mobile(user_request_reset_password_cookie['mobile']) if user_request_reset_password_cookie['medium'] == 'mobile'

    rescue SyException => e

      message = e.message

    end

    unless message.nil?

      flash[:alert] = message

      redirect_to forgot_password_users_path

    end

  end


  def resend_user_verification_code

    begin

      user_request_reset_password = cookies.encrypted[USER_ID_COOKIE_KEY.encrypt]

      raise SyException, "Verification code has been expired. Please try again." unless user_request_reset_password.present?

      @user =  User.find_by_id(user_request_reset_password['user_id'])

      raise SyException, "User not found." unless @user.present?

      @sadhak_profile = @user.sadhak_profile

      raise SyException, 'No sadhak profile found.' unless @sadhak_profile.present?

      verification_code = rand.to_s[2..7]

      cookies.encrypted[USER_ID_COOKIE_KEY.encrypt] = { value: user_request_reset_password, expires: 1.hour.from_now }

      @user.update_attribute(:verification_code, verification_code)

      if (user_request_reset_password['medium'] == "email")

        UserMailer.user_email_confirmation_notice(user_request_reset_password['email'], verification_code, @sadhak_profile).deliver_now

        @text = encrypted_email(user_request_reset_password['email'])

      elsif (user_request_reset_password['medium'] == "mobile")

        @sadhak_profile.send_sms_to_sadhak("Namah Shivay #{@sadhak_profile.try(:full_name)} Ji,\nYour mobile verification code is " + verification_code.to_s)

        @text = encrypted_mobile(user_request_reset_password['mobile'])

      end

    rescue SyException => e

      @message = e.message

    end

    res = send_verification_code_to_admin_if_admin_logged_in(verification_code, @sadhak_profile)
    medium = user_request_reset_password['medium']
    message, user_request_reset_password, @text = res if res.present?

  end


  def verify_verification_code_and_reset_password
    begin

      raise SyException, "Verification code has been expired. Please try again." unless cookies.encrypted[USER_ID_COOKIE_KEY.encrypt].present?

      user =  User.find_by_id(cookies.encrypted[USER_ID_COOKIE_KEY.encrypt]['user_id'])

      raise SyException, "User not found." unless user.present?

      @sadhak_profile = user.sadhak_profile

      raise SyException, 'No sadhak profile found.' unless @sadhak_profile.present?

      is_valid_reset_password_token = user_verification_code_params[:reset_password_token].eql? user.reset_password_token

      raise SyException, 'Invalid reset password token.' unless is_valid_reset_password_token

      raise SyException, 'Verification code cannot be blank.' unless user_verification_code_params[:verification_code]

      raise SyException, 'Invalid verification code.' if user.verification_code != user_verification_code_params[:verification_code]

      raise SyException, 'New Password cannot be blank.' unless user_verification_code_params[:new_password].present?

      raise SyException, 'Confirm Password cannot be blank.' unless user_verification_code_params[:confirm_new_password].present?

      raise SyException, 'Password and Confirm Password does not match.' if user_verification_code_params[:new_password] != user_verification_code_params[:confirm_new_password]

      raise SyException, 'New Password should be of minmium 8 characters.' if user_verification_code_params[:new_password].mb_chars.length < 8

      raise SyException, "Old password and new password cannot be same. Please enter a different password." if user.valid_password?(user_verification_code_params[:new_password])

      result = user.reset_password(user_verification_code_params[:new_password], user_verification_code_params[:confirm_new_password])

      raise SyException, 'Something went wrong please try again later.' unless result.present?

      from = GetSenderEmail.call(@sadhak_profile)
      @sadhak_profile.notify_sadhak(
        from: from,
        subject: "Password Changed Notification",
        template: 'password_changed_notification',
        message: "NMS #{@sadhak_profile.try(:syid)}-#{@sadhak_profile.try(:full_name)}\nYou have changed your password."
      ) if @sadhak_profile.email.present?

      @sadhak_profile.send_sms_to_sadhak("Namah Shivay #{@sadhak_profile.try(:full_name)} Ji,\nYou have changed your password.") if @sadhak_profile.mobile.present?

    rescue SyException => e
      message = e.message
    end

    if message.nil?

      # Delete cookies
      # cookies.delete(user.verification_code.to_s.encrypt)

      cookies.delete(USER_ID_COOKIE_KEY.encrypt)
      if signed_in?
        flash[:notice] = 'Password has been successfully changed.'
        redirect_to root_path
      else
        flash[:success] = 'Password has been successfully changed. Please login with the new Password.'
        redirect_to new_user_session_path
      end

    elsif !cookies.encrypted[USER_ID_COOKIE_KEY.encrypt].present?
    # If user delete cookie then flash error
      cookies.delete(USER_ID_COOKIE_KEY.encrypt)

      flash[:error] = message

      redirect_to forgot_password_users_path

    else

      flash[:error] = message

      # If user manipulate reset password token then redirect to confirm verification path with correct reset password token
      unless is_valid_reset_password_token
        redirect_to user_confirm_verification_code_users_path(reset_password_token: user.reset_password_token)
      else
      # Any other error occur redirect to back
        redirect_back(fallback_location: proc { root_path })
      end

    end

  end


  def edit
    @user = current_user
  end

  def update_password

    begin

      raise SyException, "Current Password cannot be blank." unless update_password_params[:current_password].present?

      raise SyException, "New Password cannot be blank." unless update_password_params[:password].present?

      raise SyException, "Confirm Password cannot be blank." unless update_password_params[:password_confirmation].present?

      raise SyException, "New password must be same as confirm password." unless update_password_params[:password].eql? update_password_params[:password_confirmation]

      @user = current_user

      raise SyException, "Incorrect current password." unless @user.valid_password?(update_password_params[:current_password])

      raise SyException, "Current password and new password cannot be same. Please enter a different password." if update_password_params[:current_password].eql? update_password_params[:password_confirmation]

      raise SyException, @user.errors.full_messages.first unless @user.update(update_password_params.except(:current_password))

      sign_in @user, :bypass => true

      flash[:success] = "Password has been successfully updated."

      redirect_to edit_v2_sadhak_profile_path(current_sadhak_profile.id, tab: "update_password")

    rescue SyException => e

      message = e.message

      flash[:alert] = message
      redirect_to edit_v2_sadhak_profile_path(current_sadhak_profile.id, tab: "update_password")

    end

  end

  def forgot_password
    # Delete cookie if exist
    cookies.delete(USER_ID_COOKIE_KEY.encrypt)
  end


  private

  def user_reset_password_params
    params.require("user").permit(:id, :syid, :date_of_birth, :mobile, :first_name, medium:[])
  end
  def update_password_params
    params.require("user").permit(:current_password, :password, :password_confirmation)
  end

  def user_verification_code_params
    params.require("user").permit(:verification_code, :new_password, :confirm_new_password, :reset_password_token)
  end

  def assert_reset_token_passed

    if params[:reset_password_token].blank?

      cookies.delete(USER_ID_COOKIE_KEY.encrypt)

      flash[:alert] = "No reset password token "

      redirect_to forgot_password_users_path

    end

  end

  def send_verification_code_to_admin_if_admin_logged_in(verification_code, sadhak_profile)
    if current_user && current_user.try(:sadhak_profile) && current_user.try(:sadhak_profile) != @sadhak_profile && current_user.try(:sadhak_profile).try(:email).present? && (current_user.super_admin? || current_user.india_admin?)

      ApplicationMailer.send_email(verification_token: (verification_code), recipients: current_user.sadhak_profile.email, subject: "Sadhak Profile Verification Token", template: 'user_mailer/sadhak_confirmation_by_admin.html.erb').deliver_now
      message, medium = nil, MEDIUM_TO_SEND_VERIFICATION_TOKEN[0]
      user_request_reset_password = { medium: medium, user_id: sadhak_profile.user_id, mobile: sadhak_profile.mobile, email:  current_user.sadhak_profile.email}
      cookies.encrypted[USER_ID_COOKIE_KEY.encrypt] = { value: user_request_reset_password, expires: 1.hour.from_now }
      text = encrypted_email(current_user.sadhak_profile.email)
      return message, user_request_reset_password, text
    end

  end

end
