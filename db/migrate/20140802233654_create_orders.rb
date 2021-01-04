class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :status
      t.string :billing_address
      t.string :billing_address_city
      t.string :billing_address_state
      t.string :billing_address_country
      t.string :billing_address_postal_code
      t.string :billing_phone
      t.string :billing_email
      t.string :billing_name
      t.string :currency
      t.decimal :total_amount
      t.string :ccavenue_tracking_id
      t.string :ccavenue_failure_message
      t.string :ccavenue_payment_mode
      t.string :ccavenue_status_code
      t.string :ccavenue_status_message
      t.string :ccavenue_customer_identifier
      t.integer :user_id
      t.timestamps
    end
  end
end
