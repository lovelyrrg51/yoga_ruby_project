class CreatePgSyHdfcPayment < ActiveRecord::Migration[5.1]
  def change
    create_table :pg_sy_hdfc_payments do |t|
      t.decimal :amount
      t.string :billing_name
      t.text :billing_address
      t.string :billing_address_city
      t.string :billing_address_postal_code
      t.string :billing_address_country
      t.string :billing_phone
      t.string :billing_email
      t.string :hdfc_tracking_id
      t.string :hdfc_failure_message
      t.string :hdfc_payment_mode
      t.string :hdfc_status_code
      t.string :billing_address_state
      t.string :hdfc_status_identifier
      t.integer :status
      t.integer :user_id
      t.integer :event_order_id
      t.integer :config_id
      t.string :m_payment_id
      
      t.timestamps
    end
  end
end
