module Api::V1
  class PaymentGatewaysController < BaseController
    before_action :authenticate_user! , :except => [:index, :show]
    before_action :locate_collection, :only => :index
    before_action :set_payment_gateway, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, :only => [:index, :show]
    respond_to :json
    # GET /payment_gateways
    def index
      render json: @payment_gateways
    end
  
    # GET /payment_gateways/1
    def show
      @payment_gateway = PaymentGateway.find(params[:id])
      render json: @payment_gateway
    end
  
    # GET /payment_gateways/new
    def new
      @payment_gateway = PaymentGateway.new
    end
  
    # GET /payment_gateways/1/edit
    def edit
    end
  
    # POST /payment_gateways
    def create
      @payment_gateway = PaymentGateway.new(payment_gateway_params)
      if @payment_gateway.save
        render json: @payment_gateway
      else
        render json: @payment_gateway.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /payment_gateways/1
    def update
      if @payment_gateway.update(payment_gateway_params)
        render json: @payment_gateway
      else
        render json: @payment_gateway.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /payment_gateways/1
    def destroy
     pg =  @payment_gateway.destroy
     render json: pg
    end
  
    def locate_collection
      if params.has_key?("filter")
        @payment_gateways = PaymentGatewayPolicy::Scope.new(current_user, PaymentGateway).resolve(filtering_params)
      else
        @payment_gateways = policy_scope(PaymentGateway)
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_payment_gateway
        @payment_gateway = PaymentGateway.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def payment_gateway_params
        params.require(:payment_gateway).permit(:payment_gateway_type_id)
      end
      def filtering_params
        params.slice(:event_id, :payment_gateway_type_id)
      end
  end
end
