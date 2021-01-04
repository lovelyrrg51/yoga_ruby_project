class CreatePaymentRefundLineItems < ActiveRecord::Migration
  def change
    create_table :payment_refund_line_items do |t|
      t.references :sadhak_profile, index: true
      t.references :event_registration, index: true
      t.integer :status
      t.references :event, index: true
      t.references :event_seating_category_association
      t.boolean :is_deleted, default: :false
      t.references :payment_refund, index: true

      t.timestamps
    end
    add_index :payment_refund_line_items, [:event_seating_category_association_id], name: 'index_payment_refund_line_items_on_seating_category_ass_id'
  end
end
