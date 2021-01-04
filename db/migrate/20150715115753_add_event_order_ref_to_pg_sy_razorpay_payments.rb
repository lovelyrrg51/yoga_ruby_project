class AddEventOrderRefToPgSyRazorpayPayments < ActiveRecord::Migration
  def change
    add_reference :pg_sy_razorpay_payments, :event_order, index: true
  end
end
