module V2
  class CountriesController < BaseController
    def index
      countries = DbCountry.all.map do |country|
        {
          id: country.id,
          name: country.name
        }
      end
      render json: countries.as_json
    end
  end
end
