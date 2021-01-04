module Api::V1::ShivyogClub
  class SyClubDigitalArrangementDetailsController < ::Api::V1::BaseController
    before_action :authenticate_user!, except: [:index, :create]
    before_action :set_sy_club_digital_arrangement_detail, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index, :create]
  
    # GET /sy_club_digital_arrangement_details
    def index
      @sy_club_digital_arrangement_details = SyClubDigitalArrangementDetail.all
      render json: @sy_club_digital_arrangement_details
    end
  
    # GET /sy_club_digital_arrangement_details/1
    def show
      render json: @sy_club_digital_arrangement_detail
    end
  
    # GET /sy_club_digital_arrangement_details/new
    def new
      @sy_club_digital_arrangement_detail = SyClubDigitalArrangementDetail.new
    end
  
    # GET /sy_club_digital_arrangement_details/1/edit
    def edit
    end
  
    # POST /sy_club_digital_arrangement_details
    def create
      @sy_club_digital_arrangement_detail = SyClubDigitalArrangementDetail.new(sy_club_digital_arrangement_detail_params)
      if @sy_club_digital_arrangement_detail.save
        render json: @sy_club_digital_arrangement_detail
      else
        render json: @sy_club_digital_arrangement_detail.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /sy_club_digital_arrangement_details/1
    def update
      authorize @sy_club_digital_arrangement_detail
      if @sy_club_digital_arrangement_detail.update(sy_club_digital_arrangement_detail_params)
        render json: @sy_club_digital_arrangement_detail
      else
        render json: @sy_club_digital_arrangement_detail.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /sy_club_digital_arrangement_details/1
    def destroy
      sy_da =  @sy_club_digital_arrangement_detail.destroy
      render json: sy_da
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sy_club_digital_arrangement_detail
        @sy_club_digital_arrangement_detail = SyClubDigitalArrangementDetail.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def sy_club_digital_arrangement_detail_params
        params.require(:sy_club_digital_arrangement_detail).permit(:lcd_size, :lcd_size, :lcd_model, :speakers_count, :speaker_model, :dvd_player_model, :generator_company, :inverter_company, :is_laptop_available, :sy_club_id, :internet_provider, :internet_speed, :internet_data_plan, :sy_club_id)
      end
  end
end
