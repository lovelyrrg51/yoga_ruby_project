module Api::V1
  class EventDiscountPlanAssociationsController < BaseController
    before_action :authenticate_user!
    before_action :set_event_discount_plan_association, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /event_discount_plan_associations
    def index
      @event_discount_plan_associations = policy_scope(EventDiscountPlanAssociation)
      render json: @event_discount_plan_associations
    end
  
    # GET /event_discount_plan_associations/1
    def show
    end
  
    # GET /event_discount_plan_associations/new
    def new
      @event_discount_plan_association = EventDiscountPlanAssociation.new
    end
  
    # GET /event_discount_plan_associations/1/edit
    def edit
    end
  
    # POST /event_discount_plan_associations
    def create
      @event_discount_plan_association = EventDiscountPlanAssociation.new(event_discount_plan_association_params)
      authorize @event_discount_plan_association
      if @event_discount_plan_association.save
        render json: @event_discount_plan_association
      else
        render json: @event_discount_plan_association.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /event_discount_plan_associations/1
    def update
      authorize @event_discount_plan_association
      if @event_discount_plan_association.update(event_discount_plan_association_params)
        render json: @event_discount_plan_association
      else
        render json: @event_discount_plan_association.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /event_discount_plan_associations/1
    def destroy
      authorize @event_discount_plan_association
      edp = @event_discount_plan_association.destroy
      render json: edp
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_discount_plan_association
        @event_discount_plan_association = EventDiscountPlanAssociation.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_discount_plan_association_params
        params.require(:event_discount_plan_association).permit(:event_id, :discount_plan_id)
      end
  end
end
