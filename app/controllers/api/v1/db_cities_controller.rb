module Api::V1
  class DbCitiesController < BaseController
    before_action :set_db_city, only: [:show, :edit, :update, :destroy]
  
    # GET /db_cities
    # GET /db_cities.json
    def index
      if params.has_key?("state_id")
        @db_state = DbState.find_by_id(params[:state_id])
        @db_cities = @db_state.try(:cities)
      else
        @db_cities = DbCity.all
       end
       render json: @db_cities
    end
  
    # GET /db_cities/1
    # GET /db_cities/1.json
    def show
      render json: @db_city
    end
  
    # GET /db_cities/new
    def new
      @db_city = DbCity.new
    end
  
    # GET /db_cities/1/edit
    def edit
    end
  
    # POST /db_cities
    # POST /db_cities.json
    def create
      @db_city = DbCity.new(db_city_params)
      if @db_city.save
        render json: @db_city
      else
        render json: @db_city.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /db_cities/1
    # PATCH/PUT /db_cities/1.json
    def update
      if @db_city.update(db_city_params)
        render json: @db_city
      else
        render json: @db_city.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /db_cities/1
    # DELETE /db_cities/1.json
    def destroy
      @db_city.destroy
      respond_to do |format|
        format.html { redirect_to db_cities_url, notice: 'Db city was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  
  
    def state
      @db_state = DbState.find(params[:id])
      @db_cities = @db_state.cities
      render json: @db_cities
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_db_city
        @db_city = DbCity.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def db_city_params
        params.require(:db_city).permit(:country_id, :name, :state_id)
      end
  end
end
