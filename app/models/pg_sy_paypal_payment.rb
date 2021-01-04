class PgSyPaypalPayment < ApplicationRecord
  belongs_to :event_order
  belongs_to :sy_club
  enum status: { pending: 0, success: 1, failure: 2 }

  def self.paypal_order_payment(paypal_payment)
    event_order = EventOrder.find_by(id: paypal_payment.event_order_id)

    if event_order
      event_order.update_attributes(
        transaction_id: paypal_payment.transaction_id,
        payment_method: 'Paypal Payment',
        status: paypal_payment.status
      )
    end

    event_order
  end

end
