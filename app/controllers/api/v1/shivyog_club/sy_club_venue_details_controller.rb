module Api::V1::ShivyogClub
  class SyClubVenueDetailsController < ::Api::V1::BaseController
    before_action :authenticate_user!, except: [:index, :create]
    before_action :set_sy_club_venue_detail, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index, :create]
  
    # GET /sy_club_venue_details
    def index
      @sy_club_venue_details = SyClubVenueDetail.all
      render json: @sy_club_venue_details
    end
  
    # GET /sy_club_venue_details/1
    def show
      render json: @sy_club_venue_detail
    end
  
    # GET /sy_club_venue_details/new
    def new
      @sy_club_venue_detail = SyClubVenueDetail.new
    end
  
    # GET /sy_club_venue_details/1/edit
    def edit
    end
  
    # POST /sy_club_venue_details
    def create
      @sy_club_venue_detail = SyClubVenueDetail.new(sy_club_venue_detail_params)
      if @sy_club_venue_detail.save
        render json: @sy_club_venue_detail
      else
        render json: @sy_club_venue_detail.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /sy_club_venue_details/1
    def update
      authorize @sy_club_venue_detail
      if @sy_club_venue_detail.update(sy_club_venue_detail_params)
      render json: @sy_club_venue_detail
      else
        render json: @sy_club_venue_detail.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /sy_club_venue_details/1
    def destroy
      sy_venue = @sy_club_venue_detail.destroy
      render json: sy_venue
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sy_club_venue_detail
        @sy_club_venue_detail = SyClubVenueDetail.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def sy_club_venue_detail_params
        params.require(:sy_club_venue_detail).permit(:venue_type, :room_size, :windows_count, :fans_count, :doors_count, :room_color, :carpet_type, :yantras_count, :sy_club_id, :lighting_arrangement, :painting_in_room, :room_other_activities, :time)
      end
  end
end
