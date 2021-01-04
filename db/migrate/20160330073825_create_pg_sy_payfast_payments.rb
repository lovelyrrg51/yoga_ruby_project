class CreatePgSyPayfastPayments < ActiveRecord::Migration
  def change
    create_table :pg_sy_payfast_payments do |t|
      t.string :name_first
      t.string :name_last
      t.string :email_address
      t.string :m_payment_id
      t.decimal :amount, precision: 10, scale: 2, default: 0.0
      t.string :item_description
      t.string :signature
      t.references :event_order, index: true
      t.references :sy_club, index: true
      t.integer :status
      t.string :pf_payment_id
      t.decimal :amount_fee, precision: 10, scale: 2, default: 0.0
      t.decimal :amount_net, precision: 10, scale: 2, default: 0.0
      t.decimal :amount_gross, precision: 10, scale: 2, default: 0.0
      t.string :currency
      t.integer :config_id
      t.boolean :is_deleted, default: false
      t.boolean :processed, default: false

      t.timestamps
    end
  end
end
