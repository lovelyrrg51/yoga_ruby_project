class ChangeStatusTypeInOrderPaymentInformation < ActiveRecord::Migration
  def change
    change_column :order_payment_informations, :status, 'integer USING CAST(status AS integer)'
  end
end
