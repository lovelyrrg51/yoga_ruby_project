module Api::V1
  class EventTeamDetailsController < BaseController
    before_action :authenticate_user!
    before_action :set_event_team_detail, only: [:show, :edit, :update, :destroy]
    respond_to :json
    # GET /event_team_details
    def index
      @event_team_details = policy_scope(EventTeamDetail)
      render json: @event_team_details
    end
  
    # GET /event_team_details/1
    def show
    end
  
    # GET /event_team_details/new
    def new
      @event_team_detail = EventTeamDetail.new
    end
  
    # GET /event_team_details/1/edit
    def edit
    end
  
    # POST /event_team_details
    def create
      @event_team_detail = EventTeamDetail.new(event_team_detail_params)
      authorize @event_team_detail
      if event_team_detail_params.has_key?("syid") and event_team_detail_params.has_key?("first_name")
        syid = event_team_detail_params[:syid]
        first_name = event_team_detail_params[:first_name]
         @sadhak_profile = SadhakProfile.where("LOWER(syid) = ? and LOWER(first_name) = ?", event_team_detail_params[:syid].downcase, event_team_detail_params[:first_name].downcase).first
  #       @sadhak_profile = SadhakProfile.new.simple_search(syid, first_name)
       if @sadhak_profile.present?
         @event_team_detail.sadhak_profile_id = @sadhak_profile.id
         if @event_team_detail.save
          render json: @event_team_detail
         else
          render json: @event_team_detail.errors, status: :unprocessable_entity
         end
       else
         render json: {error: 1, message: "Sadhak profile not found."}, status: 404
       end
     else
        render json: {error: 1, message: "Sadhak profile not found."}, status: 404
      end
    end
  
    # PATCH/PUT /event_team_details/1
    def update
      authorize @event_team_detail
      if @event_team_detail.update(event_team_detail_params)
        render json: @event_team_detail
      else
        render json: @event_team_detail.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /event_team_details/1
    def destroy
      authorize @event_team_detail
      etd = @event_team_detail.destroy
      render json: etd
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_team_detail
        @event_team_detail = EventTeamDetail.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_team_detail_params
        params.require(:event_team_detail).permit(:team_type, :role, :first_name, :syid, :event_id, :sadhak_profile_id)
      end
  end
end
