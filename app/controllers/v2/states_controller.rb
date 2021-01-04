module V2
  class StatesController < BaseController
    def index
      country = DbCountry.find params[:country_id]
      states = country.states_with_other.map do |state|
        {
          id: state.id,
          name: state.name
        }
      end
      render json: states.as_json
    end
  end
end
