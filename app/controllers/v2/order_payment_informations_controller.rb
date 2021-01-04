module V2
  class OrderPaymentInformationsController < BaseController
    skip_before_action :verify_authenticity_token, :only => [:paid, :redirect]
    
    def paid
      event_order, message, status = OrderPaymentInformation.paid(params)
      status == 'success' ? flash[:success] = 'Payment received successfully.' : flash[:error] = "Transaction Declined. Please try after some time."
      redirect_to event_order.sy_club ? complete_v2_forum_path(event_order) : complete_v2_event_order_path(event_order)
    end

    def redirect
      begin
        @event_order = CcavenuePayment.new(params, "OrderPaymentInformation").call
      rescue SyException => e
        is_error = true
      rescue => e
        is_error = true
      end
      if is_error
        redirect_to registration_details_v2_event_order_path(@event_order), flash[:error] = e.message
      else
        redirect_to @event_order.gateway_redirect_url
      end
    end
  end
end