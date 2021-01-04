module Api::V1
  class RegistrationCentersController < BaseController
    before_action :authenticate_user!, except: [:index]
    before_action :set_registration_center, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, :only => [:index]
    respond_to :json
    # GET /registration_centers
    def index
      @registration_centers = policy_scope(RegistrationCenter)
      render json: @registration_centers
    end
  
    # GET /registration_centers/1
    def show
      render json: @registration_center
    end
  
    # GET /registration_centers/new
    def new
      @registration_center = RegistrationCenter.new
    end
  
    # GET /registration_centers/1/edit
    def edit
    end
  
    # POST /registration_centers
    def create
      @registration_center = RegistrationCenter.new(registration_center_params)
      authorize @registration_center
      if @registration_center.save
        render json: @registration_center
      else
        render json: @registration_center.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /registration_centers/1
    def update
      authorize @registration_center
      if @registration_center.update(registration_center_params)
        render json: @registration_center
      else
        render json: @registration_center.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /registration_centers/1
    def destroy
      authorize @registration_center
      rc = @registration_center.destroy
      render json: rc
    end
  
    def rc_details
      raise SyException, "No registration center ids found" unless params[:reg_center_ids].present?
      rc_ids = params[:reg_center_ids].split(',')
      registration_centers = RegistrationCenter.where(id: rc_ids)
      render json: registration_centers, each_serializer: RegistrationCenterBasicDetailSerializer
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_registration_center
        @registration_center = RegistrationCenter.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def registration_center_params
        params.require(:registration_center).permit(:name, :is_cash_allowed, :start_date, :end_date, :user_ids, :user_ids => [])
      end
  end
end
