module Api::V1
  class DiscountPlansController < BaseController
    before_action :authenticate_user!, except: [:index, :show]
    before_action :set_discount_plan, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index, :show]
  
    # GET /discount_plans
    def index
      @discount_plans = DiscountPlan.all
      render json: @discount_plans
    end
  
    # GET /discount_plans/1
    def show
      render json: @discount_plan
    end
  
    # GET /discount_plans/new
    def new
      @discount_plan = DiscountPlan.new
    end
  
    # GET /discount_plans/1/edit
    def edit
    end
  
    # POST /discount_plans
    def create
      @discount_plan = DiscountPlan.new(discount_plan_params)
      @discount_plan.user_id = current_user.id  if current_user.present?
      authorize @discount_plan
      if @discount_plan.save
        render json: @discount_plan
      else
       render json: @discount_plan.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /discount_plans/1
    def update
      # authorize @discount_plan
      if @discount_plan.update(discount_plan_params)
        render json: @discount_plan
      else
       render json: @discount_plan.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /discount_plans/1
    def destroy
      authorize @discount_plan
      dp = @discount_plan.update(is_delete: 'true')
      render json: dp
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_discount_plan
        @discount_plan = DiscountPlan.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def discount_plan_params
        params.require(:discount_plan).permit(:name, :discount_type, :discount_amount, :user_id, :event_ids, :event_ids => [])
      end
  end
end
