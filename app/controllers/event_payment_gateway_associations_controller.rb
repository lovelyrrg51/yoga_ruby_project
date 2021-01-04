class EventPaymentGatewayAssociationsController < ApplicationController

  def index
  end

  def new
  end

  def create

    @event_payment_gateway_association = EventPaymentGatewayAssociation.new(event_payment_gateway_association_params)

    if @event_payment_gateway_association.save
    else
    end

    redirect_to payment_gateway_options_event_path
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def event_payment_gateway_association_params
    params.require(:event_payment_gateway_association).permit(:event_id, :payment_gateway_id, :start_date, :end_date)
  end

end
