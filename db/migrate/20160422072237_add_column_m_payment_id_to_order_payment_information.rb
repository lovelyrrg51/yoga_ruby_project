class AddColumnMPaymentIdToOrderPaymentInformation < ActiveRecord::Migration[4.2]
  def change
    add_column :order_payment_informations, :m_payment_id, :string
  end
end
