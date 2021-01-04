module Api::V1
  class PaymentGatewayTypesController < BaseController
    before_action :authenticate_user!, :except => [:index]
    before_action :set_payment_gateway_type, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, :only => [:index]
    respond_to :json
  
    # GET /payment_gateway_types
    def index
      @payment_gateway_types = PaymentGatewayType.all
      render json: @payment_gateway_types
    end
  
    # GET /payment_gateway_types/1
    def show
      render json: @payment_gateway_type
    end
  
    # GET /payment_gateway_types/new
    def new
      @payment_gateway_type = PaymentGatewayType.new
    end
  
    # GET /payment_gateway_types/1/edit
    def edit
    end
  
    # POST /payment_gateway_types
    def create
      @payment_gateway_type = PaymentGatewayType.new(payment_gateway_type_params)
      if @payment_gateway_type.save
        render json: @payment_gateway_type
      else
        render json: @payment_gateway_type.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /payment_gateway_types/1
    def update
      if @payment_gateway_type.update(payment_gateway_type_params)
        render json: @payment_gateway_type
      else
        render json: @payment_gateway_type.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /payment_gateway_types/1
    def destroy
      pgt = @payment_gateway_type.destroy
      render json: pgt
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_payment_gateway_type
        @payment_gateway_type = PaymentGatewayType.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def payment_gateway_type_params
        params.require(:payment_gateway_type).permit(:type, :config_model_name, :relation_name)
      end
  end
end
