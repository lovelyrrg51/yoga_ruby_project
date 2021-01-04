class PaymentGatewayTypesController < ApplicationController

  #before_action :set_payment_gateway_type
  before_action :authenticate_user!

  def index

    authorize(PaymentGatewayType)

    @payment_gateway_types = PaymentGatewayType.page(params[:page]).per(params[:per_page])

  end

  private

  def set_payment_gateway_type
    @payment_gateway_type = PaymentGatewayType.find(params[:id])
  end

end
