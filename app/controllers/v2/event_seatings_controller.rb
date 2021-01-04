module V2
  class EventSeatingsController < BaseController
    before_action :authenticate_user!

    def index
      event = Event.find(params[:event_id])

      serialized_data = event.event_seating_category_associations.includes(:seating_category).map do |seat|
        {
          id: seat.id,
          price: seat.price.to_f,
          category_name: seat.category_name,
          seats_available: seat.seats_available
        }
      end

      render json: serialized_data.as_json
    end

  end
end
