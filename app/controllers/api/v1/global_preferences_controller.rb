module Api::V1
  class GlobalPreferencesController < BaseController
  	before_action :authenticate_user!, except: [:index]
    before_action :set_global_preference, only: [:show, :edit, :update, :destroy]
    before_action :locate_collection, :only => :index
    respond_to :json
  
    # GET /global_preferences
    def index
      render json: @global_preferences
    end
  
    # GET /global_preferences/1
    def show
      render json: @global_preference
    end
  
    # GET /global_preferences/new
    def new
      @global_preference = GlobalPreference.new
    end
  
    # GET /global_preferences/1/edit
    def edit
    end
  
    # POST /global_preferences
    def create
      @global_preference = GlobalPreference.new(global_preference_params)
      authorize @global_preference
      if @global_preference.save
        render json: @global_preference
      else
        render json: @global_preference.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /global_preferences/1
    def update
    	authorize @global_preference
      if @global_preference.update(global_preference_params)
        render json: @global_preference
      else
        render json: @global_preference.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /global_preferences/1
    def destroy
    	authorize @global_preference
      if @global_preference.update(is_deleted: true)
        render json: @global_preference
      else
        render json: @global_preference.errors, status: :unprocessable_entity
      end
    end
  
    def locate_collection
      @global_preferences = GlobalPreferencePolicy::Scope.new(current_user, GlobalPreference).resolve(filtering_params)
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_global_preference
        @global_preference = GlobalPreference.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def global_preference_params
        params.require(:global_preference).permit(:val)
      end
  
      def filtering_params
        params.slice(:key)
      end
  end
end
