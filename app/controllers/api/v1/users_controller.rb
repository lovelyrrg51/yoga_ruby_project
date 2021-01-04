module Api::V1
  class UsersController < BaseController
    require 'digest/sha1'
    skip_before_action :verify_authenticity_token, :only => [:reset_password, :reset_user_password, :resend_confirmation_email, :test, :request_mobile_verification, :request_reset_password, :confirm_reset_password, :current, :wp_reset_password, :update_password, :permissions]
    before_action :authenticate_user!, except: [:reset_password, :reset_user_password, :resend_confirmation_email, :test, :request_mobile_verification, :confirm_mobile_verification, :request_email_verification, :confirm_email_verification, :request_reset_password, :confirm_reset_password, :current, :wp_reset_password, :update_password, :basic_user_details, :permissions]
    respond_to :json

    def index
      @title = "This is the users's index option"
      if UserPolicy.new(current_user).index?
        @users = User.all
        render json: @users
      else
        render json: { error: "Unauthorized access", status: 401 }, status: 401
      end
    end

    def show
      if UserPolicy.new(current_user).show?
        @user = User.find(params[:id])
        render json: @user
      else
        render json: { error: "Unauthorized access", status: 401 }, status: 401
      end
    end

    def current
     # authenticate_user! force: true
     # authenticate_user!
      unless current_user
        render :json => {'error' => 'authentication error'}, :status => 401
      else
        render json: current_user
      end

    end

    def reset_user_password
      reset_password_user = User.reset_password_by_token(reset_user_password_params)
      if reset_password_user.errors.count > 0
        render json: { error: reset_password_user.errors, status: 400 }, status: 400
      else
        render json: { success: "Password updated successfully", status: 200 }, status: 200
      end
    end

    def test

      delayed_job_progress = DelayedJobProgress.create!

      job = Delayed::Job.enqueue EventRegistrationsExcelReport.new(event_id: 677, format: 'xls', delayed_job_progress: delayed_job_progress)

      render json: {job_id: delayed_job_progress.id}

    end

    def reset_password
      @sadhak_profile = SadhakProfile.find_by(:email => params[:email], :syid => params[:syid].to_s.upcase )
      if @sadhak_profile.present?
        @user = @sadhak_profile.user
        if @user.nil?
          render json: { errors: {error: ["User not found."], status: 400 }}, status: 400
          # custom_error(key: 'error', message: 'User not found.')
        else
          @user.send_reset_password_instructions#(id: @user.id)
          render json: { success: {success: ["Password reset email sent successfully."], status: 200 }}, status: 200
          # custom_success(key: 'success', message: "Password reset email sent successfully.")
        end
      else
        # custom_error(key: 'error', message: 'User not found.')
        render json: { errors: {error: ["User not found."], status: 400 }}, status: 400
      end
    end

    def update_password
      if UserPolicy.new(current_user).update_password?
        begin
          user = User.find(current_user.id)
          sadhak_profile = user.sadhak_profile

          raise 'New Password cannot be blank.' unless update_password_params[:password].present?
          raise 'Confirm Password cannot be blank.' unless update_password_params[:password_confirmation].present?
          raise 'Current Password cannot be blank.' unless update_password_params[:current_password].present?
          raise 'Password and Confirm Password not match' if update_password_params[:password] != update_password_params[:password_confirmation]
          raise 'Sadhak Profile missing.' unless sadhak_profile.present?
          raise 'Incorrect current password' unless user.valid_password?(update_password_params[:current_password])
          raise 'Old password and new password cannot be same. Please enter a different password.' if user.valid_password?(update_password_params[:password])


          result = user.reset_password!(update_password_params[:password], update_password_params[:password_confirmation])
          raise 'Something went wrong please try again later.' unless result.present?
          sign_in user, :bypass => true

          from = GetSenderEmail.call(sadhak_profile)
          sadhak_profile.notify_sadhak(from: from, subject: "Password Changed Notification - #{Time.now.strftime('%d%m%Y%H%M%S%N')}", template: 'password_changed_notification', message: "NMS #{sadhak_profile.try(:syid)}-#{sadhak_profile.try(:full_name)}\nYou have changed your password. If not, kindly inform us at #{from}.")

        rescue Exception => e
          message = e.message
          is_error = true
        end
        if is_error
          render json: {message: message}, status: :unprocessable_entity
        else
          render json: {message: 'Password changed successfully.'}
        end
      else
        render json: {message: 'Unauthorized access'}, status: :unauthorized
      end
    end

    def resend_confirmation_email
      @user = User.find_by(:email => params[:email])
      if @user.nil?
        render json: { error: "User not found.", status: 400 }, status: 400
      elsif !@user.confirmed_at.nil?
        render json: { error: "User already confirmed.", status: 400 }, status: 400
      else
        @user.send_confirmation_instructions
        render json: { success: "Confirmation email sent successfully.", status: 200 }, status: 200
      end
    end

    def export_user
      @user = User.where("id < 100")
      send_data @user.to_csv, :filename => "New-user-filename.csv"
    end

    def request_mobile_verification
      if params.has_key?('contact_number') and params.has_key?('country_id')
        mobile_verification_token = SecureRandom.random_number(1000000)
        session[:mobile_verification_token] = mobile_verification_token
        logger.debug "random number"
        telephone_prefix = DbCountry.find(params[:country_id]).telephone_prefix
        country_code = DbCountry.find(params[:country_id]).ISO2
        @user = User.find_by(contact_number: params[:contact_number])
        res, message = SendSms.call(params[:contact_number], telephone_prefix, "SHIVYOG - Mobile verification code is " + session[:mobile_verification_token].to_s, country_code)
        if !message.present?
            successObj= {
              success:{
                Mobile: ["Verification code send successfully"]
                }
              }
            render json:  successObj
        else
            errorObj= {
              errors:{
                Verification: [message]
                }
              }
            render json:  errorObj, status: :unprocessable_entity
        end
      else
        render json: {errors: "please enter a valid contact number"}
      end
    end

    def confirm_mobile_verification
      if params.has_key?("verification_code") && params[:verification_code] == session[:mobile_verification_token].to_s
        successObj= {
          success:{
             Verification: ["Information successfully verified"]
            }
          }
        render json:  successObj
      else
         errorObj= {
            errors:{
              Verification: ["please check the verification code"]
              }
            }
          render json:  errorObj, status: :unprocessable_entity
      end
    end

    def request_email_verification
      if params.has_key?('email')
        email_verification_token = SecureRandom.random_number(1000000)
        logger.debug "random number"
        @email = params[:email]
        session[:email_verification_token] = email_verification_token
        @user = User.find_by(email: params[:email])
        res = UserMailer.user_email_confirmation_notice(@email, session[:email_verification_token.to_s], @user.try(:sadhak_profile)).deliver
        logger.debug "code send"
        if res
          successObj= {
            success:{
              Email: ["Verification code send successfully"]
              }
            }
          render json:  successObj
        else
          errorObj= {
            errors:{
              Verification: ["Error in sending message"]
              }
            }
              render json:  errorObj, status: :unprocessable_entity
        end
      else
        render json: {errors: "please enter a valid email_id"}
      end
    end

    def confirm_email_verification
      if params.has_key?("verification_code") && params[:verification_code] == session[:email_verification_token].to_s
        successObj= {
          success:{
            Verification: ["Information successfully verified"]
            }
          }
        render json:  successObj
      else
        errorObj= {
          errors:{
            Verification: ["please check the verification code"]
            }
          }
        render json:  errorObj, status: :unprocessable_entity
      end
    end

    def reset_sadhak_password
      begin

        raise 'You are not authorized to perform this action.' unless UserPolicy.new(current_user).reset_sadhak_password?

        sadhak_profile = SadhakProfile.find_by(id: reset_sadhak_password_params[:sadhak_profile_id], user_id: reset_sadhak_password_params[:user_id])
        user = sadhak_profile.try(:user)

        raise 'Sadhak profile cannot be blank.' unless sadhak_profile.present?
        raise 'User cannot be blank.' unless user.present?

        password = Devise.friendly_token.first(RANDOM_PASSWORD_LENGTH).to_s
        user.password = password
        user.save!

        user.email = sadhak_profile.email if sadhak_profile.email.present?
        UserMailer.reset_password_notification(user, password).deliver if user.email.present?

        success = sadhak_profile.send_sms_to_sadhak("NMS #{sadhak_profile.syid}-#{sadhak_profile.full_name}\nYour password has been successfully reset by Admin.\nYour password is: #{password}\nYou can use your username or syid for login.")

        raise 'Something went wrong while sending SMS.' unless success

      rescue Exception => e
        message = e.message
      end

      if message.present?
        errorObj= {errors:{Password: [message]}}
        render json:  errorObj, status: :unprocessable_entity
      else
        successObj= {success:{Password: ["successfully changed"]}}
        render json:  successObj
      end
    end

    def assign_role_to_users
      if params.has_key?('user_id')
        @user = User.where(id: params[:user_id]).last
        if @user.update_attributes(assign_user_role_params)
          render json: @user
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      else
        errorObj= {
          errors:{
            Role: ["no user found"]
            }
          }
        render json:  errorObj, status: :unprocessable_entity
      end
    end

    def request_reset_password
      begin
        verification_code = rand.to_s[2..7]
        if user_reset_password_params.has_key?("syid") and user_reset_password_params[:syid].present?
          syid = user_reset_password_params[:syid].strip
          syid = syid[/-?\d+/].to_i
          syid = "sy#{syid}"
          if user_reset_password_params.has_key?("first_name") and user_reset_password_params[:first_name].present?
            f_name = user_reset_password_params[:first_name].strip
            @sadhak_profiles = SadhakProfile.where("LOWER(syid) = ? and LOWER(first_name) = ?", syid.downcase, f_name.downcase).includes(:relations)
          elsif user_reset_password_params.has_key?("mobile") and user_reset_password_params[:mobile].present?
            mobile = user_reset_password_params[:mobile]
            @sadhak_profiles = SadhakProfile.where("LOWER(syid) = ? and mobile = ?", syid.downcase, mobile).includes(:relations)
          elsif user_reset_password_params.has_key?("date_of_birth") and user_reset_password_params[:date_of_birth].present?
            dob = user_reset_password_params[:date_of_birth].strip.to_date
            @sadhak_profiles = SadhakProfile.where("LOWER(syid) = ? and date_of_birth = ?", syid.downcase, dob).includes(:relations)
          end
          raise SyException.new("No sadhak profile found. Please input a valid combination.") if @sadhak_profiles.count == 0
          @sadhak_profile = @sadhak_profiles.last
          raise SyException.new("Sadhak profile found but no user associated with sadhak. Please contact Asharam.") if @sadhak_profile.user.nil?
          @user = @sadhak_profile.user
          raise SyException.new("NMS #{@sadhak_profile.full_name}, You are not allowed to reset password. Please contact Ashram.") if @sadhak_profile.banned?
          user_updated = @user.update_attribute("verification_code", verification_code)
          raise SyException.new("Something went wrong while updating verification code in database. Please try again.") unless user_updated
          if user_reset_password_params[:medium].nil?
            is_email_present = @sadhak_profile.email.present?
            is_email_verified = @sadhak_profile.is_email_verified?
            is_mobile_present = @sadhak_profile.mobile.present?
            is_mobile_verified = @sadhak_profile.is_mobile_verified?
            is_default = true
          elsif user_reset_password_params[:medium] == 'email'
            is_email_present = @sadhak_profile.email.present?
            raise SyException.new("No email present. Please update email and try again.") unless is_email_present
            is_email_verified = true
            is_default = false
          elsif user_reset_password_params[:medium] == 'mobile'
            is_mobile_present = @sadhak_profile.mobile.present?
            raise SyException.new("No mobile number present. Please update mobile number and try again.") unless is_mobile_present
            is_mobile_verified = true
            is_default = false
          else
            raise SyException.new("Not a valid medium to notify sadhak. Please input a valid input method (Email or Mobile).")
          end
          if is_email_present and is_email_verified
            res = UserMailer.user_email_confirmation_notice(@sadhak_profile.email, verification_code, @sadhak_profile).deliver
            raise SyException.new("There is some error occured while sending email. Please try again.") if !res
          elsif is_mobile_present and is_mobile_verified
            raise SyException.new("Country is missing. Please update sadhak profile address.") if @sadhak_profile.address.country_id.nil?
            country_id = @sadhak_profile.address.country_id
            telephone_prefix = DbCountry.find(country_id).telephone_prefix
            country_code = DbCountry.find(country_id).ISO2
            res, message = SendSms.call(@sadhak_profile.mobile, telephone_prefix, "Namah Shivay #{@sadhak_profile.try(:full_name)} Ji,\nYour mobile verification code is " + verification_code.to_s, country_code)
            raise SyException.new(message) if message.present?
          elsif is_default and @user.email.present?
            res = UserMailer.user_email_confirmation_notice(@sadhak_profile.user.email, verification_code, @sadhak_profile).deliver
            raise SyException.new("There is some error occured while sending email. Please try again.") if !res
          else
            raise SyException.new("Not a valid medium to notify sadhak. Please input a valid input method(Email or Mobile).")
          end
        else
          raise SyException.new("Please input a valid SYID.")
        end
      rescue SyException => e
        message = e.message
        logger.info("Manual exception: #{message}")
      rescue Exception => e
        message = e.message
        logger.info(e)
        logger.info(e.backtrace)
      end
      if message.nil?
        render json: @sadhak_profile, serializer: UserVerificationSerializer
      else
        errorObj= {errors:{message: [message]}}
        render json:  errorObj, status: :unprocessable_entity
      end
    end

    def confirm_reset_password
      begin
        user = User.find_by_id(reset_password_params[:user_id])
        raise 'User not found.' unless user.present?

        sadhak_profile = user.sadhak_profile
        raise 'No associated sadhak profile found with user.' unless sadhak_profile.present?

        raise 'Verification code cannot be blank.' unless reset_password_params[:token]
        raise 'New Password cannot be blank.' unless reset_password_params[:new_password].present?
        raise 'Confirm Password cannot be blank.' unless reset_password_params[:confirm_new_password].present?
        raise 'Password and Confirm Password does not match' if reset_password_params[:new_password] != reset_password_params[:confirm_new_password]
        raise 'Invalid verification code.' if user.verification_code != reset_password_params[:token]
        raise 'New Password should be of minmium 8 characters.' if reset_password_params[:new_password].mb_chars.length < 8
        raise 'Old password and new password cannot be same. Please enter a different password.' if user.valid_password?(reset_password_params[:new_password])

        result = user.reset_password!(reset_password_params[:new_password], reset_password_params[:confirm_new_password])
        raise 'Something went wrong please try again later.' unless result.present?

        from = GetSenderEmail.call(sadhak_profile)
        sadhak_profile.notify_sadhak(from: from, subject: "Password Changed Notification - #{Time.now.strftime('%d%m%Y%H%M%S%N')}", template: 'password_changed_notification', message: "NMS #{sadhak_profile.try(:syid)}-#{sadhak_profile.try(:full_name)}\nYou have changed your password.")

      rescue Exception => e
        message = e.message
        is_error = true
      end

      unless is_error
        successObj= {success: {message: 'Password successfully changed'} }
        render json:  successObj
      else
        errorObj= {errors: {message: [message]} }
        render json:  errorObj, status: :unprocessable_entity
      end
    end

    def wp_reset_password
      if UserPolicy.new(current_user).wp_reset_password?
        begin
          raise 'SYID cannot be blank.' unless wp_reset_password_params[:sadhak_profile_id].present?
          raise 'Password cannot be blank' unless wp_reset_password_params[:password].present?
          sadhak_profile = SadhakProfile.find(wp_reset_password_params[:sadhak_profile_id])
          raise 'Sadhak Profile not found.' unless sadhak_profile.present?
          raise 'Sadhak Profile is banned.' if sadhak_profile.banned?
          user = sadhak_profile.user
          raise 'User not found.' unless user.present?
          user.password = wp_reset_password_params[:password]
          raise user.errors.full_messages.first unless user.save
        rescue Exception => e
          message = e.message
          is_error = true
        end
        if is_error
          render json: {error: message}, status: :unprocessable_entity
        else
          render json: {success: 'Password changed successfully.'}
        end
      else
        render json: {error: 'Unauthorized access'}, status: :unauthorized
      end
    end

    def basic_user_details
      if current_user.present? and current_user.sadhak_profile.present?
        render json: current_user, serializer: ChromeUserBasicDetailSerializer, root: 'user', adapter: :json
      else
        render json: {error: ['Unauthorised access.']}
      end
    end

    def permissions
      render json: current_user.try(:user_permissions) || {}
    end

    private
    def reset_user_password_params
      params.permit(:reset_password_token, :password, :password_confirmation)
    end

    def reset_sadhak_password_params
      params.permit(:term, :user_id, :sadhak_profile_id)
    end

    def assign_user_role_params
      params.permit(:photo_approval_admin, :super_admin, :event_admin, :digital_store_admin, :group_admin, :club_admin, :india_admin)
    end

    def user_reset_password_params
      params.require(:sadhak_profile).permit!#(:syid, :first_name, :ownership_request_token)
    end

    def reset_password_params
      params.require(:sadhak_profile).permit!#(:syid, :first_name, :ownership_request_token)
    end

    def wp_reset_password_params
      params.require(:user).permit(:sadhak_profile_id, :password)
    end

    def update_password_params
      params.require(:user).permit(:password, :password_confirmation, :current_password)
    end

  end
end
