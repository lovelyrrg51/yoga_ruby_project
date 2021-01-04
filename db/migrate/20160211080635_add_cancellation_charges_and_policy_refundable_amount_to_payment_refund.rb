class AddCancellationChargesAndPolicyRefundableAmountToPaymentRefund < ActiveRecord::Migration
  def change
    add_column :payment_refunds, :policy_refundable_amount, :decimal, precision: 10, scale: 2, default: 0.00
    add_column :payment_refunds, :cancellation_charges, :decimal, precision: 10, scale: 2, default: 0.00
  end
end
