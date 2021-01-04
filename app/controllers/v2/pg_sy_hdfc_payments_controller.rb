module V2
  class PgSyHdfcPaymentsController < BaseController
    skip_before_action :verify_authenticity_token, :only => [:redirect, :paid]
    def redirect
      begin
        @event_order = CcavenuePayment.new(params, "PgSyHdfcPayment").call
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

    def paid
      event_order, message, status, transaction_log = PgSyHdfcPayment.paid(params)
      status == 'success' ? flash[:success] = 'Payment received successfully.' : flash[:error] = message
      if status.eql?("tampering")
        redirect_to event_order.sy_club ? register_v2_forum_path(event_order.sy_club) : v2_event_path(event_order.event)
      elsif status.eql?("success") || status.eql?("failure")
        redirect_to event_order.sy_club ? complete_v2_forum_path(event_order) : hdfc_complete_v2_event_order_path(event_order, transaction_log_id: transaction_log&.id)
      else
        redirect_to root_path
      end
    end
  end
end