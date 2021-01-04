module Api::V1
  class SpiritualJourneysController < BaseController
    before_action :authenticate_user!, except: [:index, :show, :create, :update]
    before_action :set_spiritual_journey, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index, :create, :update]
    # GET /spiritual_journeys
    def index
      @spiritual_journeys = policy_scope(SpiritualJourney)
      render json: @spiritual_journeys
    end
  
    # GET /spiritual_journeys/1
    def show
      authorize @spiritual_journey
      render json: @spiritual_journey
    end
  
    # GET /spiritual_journeys/new
    def new
      @spiritual_journey = SpiritualJourney.new
    end
  
    # GET /spiritual_journeys/1/edit
    def edit
    end
  
    # POST /spiritual_journeys
    def create
      @spiritual_journey = SpiritualJourney.new(spiritual_journey_params)
      # authorize @spiritual_journey
      if @spiritual_journey.save
        render json: @spiritual_journey
      else
        render json: @spiritual_journey.errors, status: :unprocessable_entity
      end

    end
  
    # PATCH/PUT /spiritual_journeys/1
    def update
      # authorize @spiritual_journey
      if @spiritual_journey.update(spiritual_journey_params)
        render json: @spiritual_journey
      else
        render json: @spiritual_journey.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /spiritual_journeys/1
    def destroy
      authorize @spiritual_journey
      res = @spiritual_journey.destroy
      render json: res
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_spiritual_journey
        @spiritual_journey = SpiritualJourney.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def spiritual_journey_params
        params.require(:spiritual_journey).permit(:source_of_information, :reason_for_joining, :first_event_attended, :first_event_attended_year, :first_event_attended_month, :sadhak_profile_id, :alternative_source, :source_info_type_id)
      end
  end
end
