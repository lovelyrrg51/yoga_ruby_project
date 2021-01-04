class CreatePaymentRefunds < ActiveRecord::Migration
  def change
    create_table :payment_refunds do |t|
      t.integer :requester_id
      t.integer :responder_id
      t.decimal :amount_refunded, precision: 10, scale: 2, default: 0.00
      t.references :event_order, index: true
      t.references :event, index: true
      t.integer :action
      t.integer :status
      t.boolean :is_deleted, default: :false
      t.text :request_object
      t.decimal :max_refundable_amount, precision: 10, scale: 2, default: 0.00
      t.references :event_cancellation_plan, index: true
      t.string :ip

      t.timestamps
    end
    add_foreign_key :payment_refunds, :users, column: :requester_id
    add_foreign_key :payment_refunds, :users, column: :responder_id
    add_index :payment_refunds, :requester_id
    add_index :payment_refunds, :responder_id
  end
end
