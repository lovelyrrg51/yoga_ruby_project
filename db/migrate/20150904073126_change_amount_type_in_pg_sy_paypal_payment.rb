class ChangeAmountTypeInPgSyPaypalPayment < ActiveRecord::Migration
  def change
    def up
      change_column :pg_sy_paypal_payments, :amount, :decimal, precision: 10, scale: 2
    end

    def down
      change_column :pg_sy_paypal_payments, :amount, :integer
    end
  end
end
