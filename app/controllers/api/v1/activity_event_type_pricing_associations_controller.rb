module Api::V1
  class ActivityEventTypePricingAssociationsController < BaseController
    before_action :set_activity_event_type_pricing_association, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!, except: [:index, :create, :show]
    before_action :locate_collection, :only => :index
    skip_before_action :verify_authenticity_token, :only => [:index, :create, :show]
    respond_to :json
  
    # GET /activity_event_type_pricing_associations
    def index
      @activity_event_type_pricing_associations = ActivityEventTypePricingAssociation.all
      render json: @activity_event_type_pricing_associations
    end
  
    # GET /activity_event_type_pricing_associations/1
    def show
      render json: @activity_event_type_pricing_association
    end
  
    # GET /activity_event_type_pricing_associations/new
    def new
      @activity_event_type_pricing_association = ActivityEventTypePricingAssociation.new
    end
  
    # GET /activity_event_type_pricing_associations/1/edit
    def edit
    end
  
    # POST /activity_event_type_pricing_associations
    def create
      @activity_event_type_pricing_association = ActivityEventTypePricingAssociation.new(activity_event_type_pricing_association_params)
      authorize @activity_event_type_pricing_association
      if @activity_event_type_pricing_association.save
        render json: @activity_event_type_pricing_association
      else
       render json: @activity_event_type_pricing_association.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /activity_event_type_pricing_associations/1
    def update
      authorize @activity_event_type_pricing_association
      if @activity_event_type_pricing_association.update(activity_event_type_pricing_association_params)
        render json: @activity_event_type_pricing_association
      else
        render json: @activity_event_type_pricing_association.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /activity_event_type_pricing_associations/1
    # DELETE /activity_event_type_pricing_associations/1.json
    def destroy
      authorize @activity_event_type_pricing_association
      activity_event_type_pricing_association = @activity_event_type_pricing_association.destroy
      render json: activity_event_type_pricing_association
    end
  
    def locate_collection
      if params.has_key?("filter")
        @activity_event_type_pricing_associations = ActivityEventTypePricingAssociationPolicy::Scope.new(current_user, ActivityEventTypePricingAssociation).resolve(filtering_params)
      else
        @activity_event_type_pricing_associations = policy_scope(ActivityEventTypePricingAssociation)
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_activity_event_type_pricing_association
        @activity_event_type_pricing_association = ActivityEventTypePricingAssociation.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def activity_event_type_pricing_association_params
        params.require(:activity_event_type_pricing_association).permit(:event_id, :event_type_pricing_id)
      end
  
      def filtering_params
        params.slice(:event_id)
      end
  end
end
