module Api::V1
  class SadhakSevaPreferencesController < BaseController
    before_action :authenticate_user!, except: [:create, :show, :update]
    before_action :set_sadhak_seva_preference, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, :only => [:update, :create, :show]
  
    # GET /sadhak_seva_preferences
    def index
      @sadhak_seva_preferences = SadhakSevaPreference.all
      render json: @sadhak_seva_preferences
    end
  
    # GET /sadhak_seva_preferences/1
    def show
      render json: @sadhak_seva_preference
    end
  
    # GET /sadhak_seva_preferences/new
    def new
      @sadhak_seva_preference = SadhakSevaPreference.new
    end
  
    # GET /sadhak_seva_preferences/1/edit
    def edit
    end
  
    # POST /sadhak_seva_preferences
    def create
      @sadhak_seva_preference = SadhakSevaPreference.new(sadhak_seva_preference_params)
      # authorize @sadhak_seva_preference
      if @sadhak_seva_preference.save
        render json: @sadhak_seva_preference
      else
        render json: @sadhak_seva_preference.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /sadhak_seva_preferences/1
    def update
      # authorize @sadhak_seva_preference
      if @sadhak_seva_preference.update(sadhak_seva_preference_params)
        render json: @sadhak_seva_preference
      else
        render json: @sadhak_seva_preference.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /sadhak_seva_preferences/1
    def destroy
      authorize @sadhak_seva_preference
      seva_preference = @sadhak_seva_preference.destroy
      render json: seva_preference
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sadhak_seva_preference
        @sadhak_seva_preference = SadhakSevaPreference.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def sadhak_seva_preference_params
        params.require(:sadhak_seva_preference).permit(:voluntary_organisation, :seva_preference, :other_seva_preference, :availability, :sadhak_profile_id, :expertise)
      end
  end
end
