class CreatePaymentGatewayTypes < ActiveRecord::Migration
  def change
    create_table :payment_gateway_types do |t|
      t.string :type
      t.string :config_model_name
      t.string :relation_name

      t.timestamps
    end
  end
end
