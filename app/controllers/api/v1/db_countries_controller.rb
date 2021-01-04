module Api::V1
  class DbCountriesController < BaseController
    before_action :set_db_country, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /db_countries
    def index
      @db_countries = DbCountry.all
      render json: @db_countries
    end
  
    # GET /db_countries/1
    # GET /db_countries/1.json
    def show
    end
  
    # GET /db_countries/new
    def new
      @db_country = DbCountry.new
    end
  
    # GET /db_countries/1/edit
    def edit
    end
  
    # POST /db_countries
    # POST /db_countries.json
    def create
      @db_country = DbCountry.new(db_country_params)
      if @db_country.save
        render json: @db_country
      else
        render json: @db_country.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /db_countries/1
    # PATCH/PUT /db_countries/1.json
    def update
      if @db_country.update(db_country_params)
        render json: @db_country
      else
        render json: @db_country.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /db_countries/1
    # DELETE /db_countries/1.json
    def destroy
      @db_country.destroy
      respond_to do |format|
        format.html { redirect_to db_countries_url, notice: 'Db country was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_db_country
        @db_country = DbCountry.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def db_country_params
        params[:db_country].permit!
      end
  end
end
