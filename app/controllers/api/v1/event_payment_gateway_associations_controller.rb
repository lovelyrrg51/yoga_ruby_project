module Api::V1
  class EventPaymentGatewayAssociationsController < BaseController
    before_action :authenticate_user!, except: [:index]
    before_action :set_event_payment_gateway_association, only: [:show, :edit, :update, :destroy]
    before_action :locate_collection, :only => :index
    skip_before_action :verify_authenticity_token, :only => [:index]
    respond_to :json
  
  
    # GET /event_payment_gateway_associations
    def index
      render json: @event_payment_gateway_associations
    end
  
    # GET /event_payment_gateway_associations/1
    def show
    end
  
    # GET /event_payment_gateway_associations/new
    def new
      @event_payment_gateway_association = EventPaymentGatewayAssociation.new
    end
  
    # GET /event_payment_gateway_associations/1/edit
    def edit
    end
  
    # POST /event_payment_gateway_associations
    def create
      @event_payment_gateway_association = EventPaymentGatewayAssociation.new(event_payment_gateway_association_params)
      if @event_payment_gateway_association.save
        render json: @event_payment_gateway_association
      else
        render json: @event_payment_gateway_association.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /event_payment_gateway_associations/1
    def update
      if @event_payment_gateway_association.update(event_payment_gateway_association_params)
        render json: @event_payment_gateway_association
      else
        render json: @event_payment_gateway_association.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /event_payment_gateway_associations/1
    def destroy
      epga = @event_payment_gateway_association.destroy
      render json: epga
    end
  
     def locate_collection
      if (params.has_key?("filter"))
        @event_payment_gateway_associations = EventPaymentGatewayAssociationPolicy::Scope.new(current_user, EventPaymentGatewayAssociation).resolve(filtering_params)
      else
        @event_payment_gateway_associations = policy_scope(EventPaymentGatewayAssociation)
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
    def set_event_payment_gateway_association
      @event_payment_gateway_association = EventPaymentGatewayAssociation.find(params[:id])
    end
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def event_payment_gateway_association_params
      params.require(:event_payment_gateway_association).permit(:event_id, :payment_gateway_id, :payment_start_date, :payment_end_date)
    end
  
    def filtering_params
      params.slice(:event_id)
    end
  end
end
