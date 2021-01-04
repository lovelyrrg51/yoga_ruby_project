module V2
  class EventWizardController < BaseController
    include PaymentGatewayFormsHelper

    before_action :set_event, only: [:verify_member, :create_event_order, :pay]

    # POST /events/1993/verify_member.json
    def verify_member
      @sadhak_profile = SadhakProfile.find(sadhak_profile_params[:id])

      #raise exception if no sadhak profile found after search.
      raise "No Sadhak Profile found." unless @sadhak_profile.present?

      #check if searched sadhak is valid to register in the event.
      @sadhak_profile.verify_registration_for_event(@event)

      render json: { success: true }

    rescue StandardError => e
      Rollbar.error(e)
      Rails.logger.info(e)
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def create_event_order
      # Todo
    end

    def pay
      # Todo
    end

    private

    def set_event
      @event = Event.find(params[:id])
    end

    def sadhak_profile_params
      params.require(:sadhak_profile).permit([:id])
    end

  end
end