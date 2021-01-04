module Api::V1
  class DbStatesController < BaseController
    before_action :set_db_state, only: [:show, :edit, :update, :destroy]
  
    # GET /db_states
    # GET /db_states.json
    def index
      if params.has_key?("country_id")
        @db_country = DbCountry.find(params[:country_id])
        #@db_state = DbState.where((country_id: params[:id]))
        @db_states = @db_country.states
      else
        @db_states = DbState.all
      end
      render json: @db_states
    end
  
    # GET /db_states/1
    # GET /db_states/1.json
    def show
      render json: @db_state
    end
  
    # GET /db_states/new
    def new
      @db_state = DbState.new
    end
  
    # GET /db_states/1/edit
    def edit
    end
  
    # POST /db_states
    def create
      @db_state = DbState.new(db_state_params)
      if @db_state.save
        render json: @db_state
      else
        render json: @db_state.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /db_states/1
    # PATCH/PUT /db_states/1.json
    def update
      if @db_state.update(db_state_params)
        render json: @db_state
      else
        render json: @db_state.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /db_states/1
    # DELETE /db_states/1.json
    def destroy
      state =  @db_state.destroy
      render json: state
    end
  
    def country
      @db_country = DbCountry.find(params[:id])
      #@db_state = DbState.where((country_id: params[:id]))
      @db_states = @db_country.states
      render json: @db_states
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_db_state
        @db_state = DbState.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def db_state_params
        params.require(:db_state).permit(:country_id, :name, :code, :adm1_code)
      end
  end
end
