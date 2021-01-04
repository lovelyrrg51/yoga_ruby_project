class AddSyClubIdToPaymentModel < ActiveRecord::Migration
  def change
    add_reference :pg_cash_payment_transactions, :sy_club, index: true
    add_reference :pg_sydd_transactions, :sy_club, index: true
    add_reference :pg_sy_razorpay_payments , :sy_club, index: true
    add_reference :pg_sy_braintree_payments, :sy_club, index: true
    add_reference :pg_sy_paypal_payments, :sy_club, index: true
  end
end
