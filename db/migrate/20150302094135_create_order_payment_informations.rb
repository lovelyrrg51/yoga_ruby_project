class CreateOrderPaymentInformations < ActiveRecord::Migration
  def change
    create_table :order_payment_informations do |t|
      t.decimal :amount
      t.string :billing_name
      t.text :billing_address
      t.string :billing_address_city
      t.string :billing_address_postal_code
      t.string :billing_address_country
      t.string :billing_phone
      t.string :billing_email
      t.string :ccavenue_tracking_id
      t.string :ccavenue_failure_message
      t.string :ccavenue_payment_mode
      t.string :ccavenue_status_code
      t.string :billing_address_state
      t.string :ccavenue_status_identifier
      t.string :status
      t.references :user
      t.foreign_key :users
      
      t.timestamps
    end
  end
end
