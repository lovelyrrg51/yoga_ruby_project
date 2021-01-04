module V2
  class VerifySadhakProfilesController < BaseController
    before_action :authenticate_user!

    def show
    end

    def send_email_verification
      sadhak_profile = SadhakProfile.friendly.find(params[:sadhak_profile_id])
      authorize sadhak_profile

      raise ArgumentError unless sadhak_profile.email_verification_needed?

      sadhak_profile.send_email_verification

      cookies[RESEND_TIMER_KEY] = { value: RESEND_TIMER, expires: RESEND_TIMER.seconds.from_now }
      respond_to do |format|
        format.html { flash[:success] = 'Verification token has been sent to your email!'; redirect_to v2_sadhak_profile_verify_sadhak_profile_path(sadhak_profile) }
        format.json { render json: { message: 'Verification token has been sent to your email!'} }
      end
    end

    def send_mobile_verification
      sadhak_profile = SadhakProfile.friendly.find(params[:sadhak_profile_id])
      authorize sadhak_profile

      raise ArgumentError unless sadhak_profile.mobile_verification_needed?

      sadhak_profile.send_mobile_verification

      cookies[RESEND_TIMER_KEY] = { value: RESEND_TIMER, expires: RESEND_TIMER.seconds.from_now }
      respond_to do |format|
        format.html { flash[:success] = 'Verification token has been sent to your mobile!'; redirect_to v2_sadhak_profile_verify_sadhak_profile_path(sadhak_profile) }
        format.json { render json: { message: 'Verification token has been sent to your mobile!'} }
      end
    end

    def verify
      sadhak_profile = SadhakProfile.friendly.find(params[:sadhak_profile_id])
      authorize sadhak_profile

      case
      when sadhak_profile.mobile_verification_token == params[:token]
        sadhak_profile.update!(is_mobile_verified: true)
        head :no_content
      when sadhak_profile.email_verification_token == params[:token]
        sadhak_profile.update!(is_email_verified: true)
        head :no_content
      else
        raise ArgumentError, 'Incorrect verification code'
      end
    rescue => e
      render json: {
          success: false,
          message: e.message
      }, status: :unprocessable_entity
    end

    def resend
      sadhak_profile = SadhakProfile.friendly.find(params[:sadhak_profile_id])
      authorize sadhak_profile

      sadhak_profile.send_email_verification if sadhak_profile.email_verification_needed?
      sadhak_profile.send_mobile_verification if sadhak_profile.mobile_verification_needed?
      sadhak_profile.send_verification_token_to_admin if (current_user&.super_admin? || current_user&.india_admin?)

      if sadhak_profile.save
        head :no_content
        cookies[RESEND_TIMER_KEY] = { value: RESEND_TIMER, expires: RESEND_TIMER.seconds.from_now }
      else
        render json: {
            success: false,
            message: sadhak_profile.errors.full_messages.first
        }, status: :unprocessable_entity
      end
    end
  end
end
