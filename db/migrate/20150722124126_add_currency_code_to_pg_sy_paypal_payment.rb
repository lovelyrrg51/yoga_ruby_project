class AddCurrencyCodeToPgSyPaypalPayment < ActiveRecord::Migration
  def change
    add_column :pg_sy_paypal_payments, :currency_code, :string
  end
end
