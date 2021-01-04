class AddCorrelationIdToPgSyPaypalPayments < ActiveRecord::Migration
  def change
    add_column :pg_sy_paypal_payments, :correlation_id, :string
  end
end
