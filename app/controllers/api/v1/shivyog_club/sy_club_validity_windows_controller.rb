module Api::V1::ShivyogClub
  class SyClubValidityWindowsController < ::Api::V1::BaseController
    before_action :authenticate_user!, except: [:index, :create]
    before_action :set_sy_club_validity_window, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index, :create]
  
    # GET /sy_club_validity_windows
    def index
      @sy_club_validity_windows = policy_scope(SyClubValidityWindow)
      render json: @sy_club_validity_windows
    end
  
    # GET /sy_club_validity_windows/1
    def show
      render json: @sy_club_validity_window
    end
  
    # GET /sy_club_validity_windows/new
    def new
      @sy_club_validity_window = SyClubValidityWindow.new
    end
  
    # GET /sy_club_validity_windows/1/edit
    def edit
    end
  
    # POST /sy_club_validity_windows
    def create
      @sy_club_validity_window = SyClubValidityWindow.new(sy_club_validity_window_params)
      authorize @sy_club_validity_window
      if @sy_club_validity_window.save
        render json: @sy_club_validity_window
      else
        render json: @sy_club_validity_window.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /sy_club_validity_windows/1
    def update
      authorize @sy_club_validity_window
      if @sy_club_validity_window.update(sy_club_validity_window_params)
        render json: @sy_club_validity_window
      else
        render json: @sy_club_validity_window.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /sy_club_validity_windows/1
    def destroy
      authorize @sy_club_validity_window
      sy_club_win_val = @sy_club_validity_window.destroy
      render json: sy_club_win_val
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sy_club_validity_window
        @sy_club_validity_window = SyClubValidityWindow.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def sy_club_validity_window_params
        params.require(:sy_club_validity_window).permit(:club_reg_start_date, :club_reg_end_date, :membership_start_date, :membership_end_date)
      end
  end
end
