module V2
  class EventsController < BaseController
    before_action :authenticate_user!, only: [:register_members]

    def index
      events = Event.includes(:address)
        .where('event_start_date > ?', 6.months.ago)
        .select(:id, :event_name, :graced_by,
          :event_start_date, :event_end_date, :cannonical_event_id)

      @events = events.map do |e|
          {
            id: e.id,
            event_name: e.event_name,
            graced_by: e.graced_by,
            event_start_date: e.event_start_date,
            event_end_date: e.event_end_date,
            cannonical_event_id: e.cannonical_event_id,
            event_address: e.event_address,
          }
        end
    end

    def show
      @event = Event.friendly.find params[:id]

      @seat_data = @event.event_seating_category_associations.includes(:seating_category).map do |seat|
        {
            id: seat.id,
            price: seat.price.to_f,
            category_name: seat.category_name,
            seats_available: seat.seats_available
        }
      end
    end

    def upcoming
      @q = Event.upcoming.ransack(params[:q])
      @events = EventDecorator.decorate_collection(
        @q.result(distinct: true).page(params[:page]).per(params[:per_page])
      )
    end

    def register_members
      sadhak_profiles = []
      params[:members].each do |member_params|
        # ignore empty member
        next if member_params[:is_new_profile] == false && member_params[:profile].nil?

        if member_params[:is_new_profile]
          sadhak_profile_params = member_params[:new_profile][:sadhak_profile].permit(
            :first_name, :last_name, :gender, :date_of_birth, :email, :mobile
          )
          address_params = member_params[:new_profile][:address].permit(
            :first_line, :second_line, :city_id, :state_id, :country_id,
            :other_state, :other_city, :postal_code
          )
          sadhak_profile = CreateSadhakProfile.call(
            sadhak_profile_params: sadhak_profile_params,
            address_params: address_params,
            user: current_user
          ).sadhak_profile
        else
          # existing sadhak profile
          sadhak_profile = SadhakProfile.find member_params.dig(:profile, :id)
        end

        sadhak_profile.temp_id = member_params[:temp_id]
        sadhak_profiles << sadhak_profile
      end

      serialized_data = sadhak_profiles.map do |sadhak_profile|
        {
          temp_id: sadhak_profile.temp_id,
          id: sadhak_profile.id,
          full_name: sadhak_profile.full_name,
          gender: sadhak_profile.gender,
          obscure_email: Utilities::MaskEmail.call(sadhak_profile.email),
          obscure_mobile: Utilities::Mobile.new(sadhak_profile.mobile).masked_number,
          city: sadhak_profile.city_name,
          state: sadhak_profile.state_name,
          country: sadhak_profile.country_name,
          error_messages: sadhak_profile.errors.full_messages
        }
      end

      success = sadhak_profiles.present? && sadhak_profiles.all?(&:persisted?)

      if success
        render json: {
          success: true,
          members: serialized_data
        }
      else
        render json: {
          success: false,
          members: serialized_data
        }, status: :unprocessable_entity
      end
    end
  end
end
