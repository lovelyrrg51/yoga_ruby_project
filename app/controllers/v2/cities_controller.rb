module V2
  class CitiesController < BaseController
    def index
      state = DbState.find params[:state_id]
      cities = state.cities_with_other.map do |city|
        {
          id: city.id,
          name: city.name
        }
      end
      render json: cities.as_json
    end
  end
end
