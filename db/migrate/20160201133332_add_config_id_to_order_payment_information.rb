class AddConfigIdToOrderPaymentInformation < ActiveRecord::Migration
  def change
    add_column :order_payment_informations, :config_id, :integer
  end
end
