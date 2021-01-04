module V2
  class ForgotSyidsController < BaseController

    def show
    end

    def search_by_email
      sadhak_profiles = SadhakProfile.where(email: params[:email].strip.downcase).limit(10)

      if sadhak_profiles.any?
        UserMailer.send_syid_list(params[:email], nil, sadhak_profiles).deliver!
        head :no_content
      else
        render json: {
          success: false,
          message: 'No records found!'
        }, status: :unprocessable_entity
      end
    end

    def search_by_mobile
      mobile = Utilities::Mobile.new(params[:mobile]).parsed_number
      sadhak_profiles = SadhakProfile.where(mobile: mobile).limit(10)

      if sadhak_profiles.any?
        message = sadhak_profiles.map { |e| "#{e.syid}-#{e.first_name}" }.join("\n")
        sadhak_profiles.last.delay.send_sms_to_sadhak(message)
        head :no_content
      else
        render json: {
          success: false,
          message: 'No records found!'
        }, status: :unprocessable_entity
      end
    end

    def search_by_details
      filter_params = params.slice(:first_name, :last_name, :date_of_birth,
        :country_id, :state_id, :city_id).select { |_, v| v.present? }
      sadhak_profiles = SadhakProfile.filter(filter_params)
      case sadhak_profiles.count
      when 0
        render json: {
          success: false,
          message: 'No records found!'
        }, status: :unprocessable_entity
      when 1
        sadhak_profile = sadhak_profiles.first
        render json: {
          success: true,
          message: "Your Sadhak Profile is - SYID: #{sadhak_profile.syid}, First name: #{sadhak_profile.first_name}."
        }
      else
        render json: {
          success: false,
          message: 'Multiple Sadhak profiles found. Please do more precise search.'
        }, status: :unprocessable_entity
      end
    end

  end
end
