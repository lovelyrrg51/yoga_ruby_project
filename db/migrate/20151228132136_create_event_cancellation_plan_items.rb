class CreateEventCancellationPlanItems < ActiveRecord::Migration
  def change
    create_table :event_cancellation_plan_items do |t|
      t.references :event_cancellation_plan
      t.integer :days_before
      t.decimal :amount, precision: 10, scale: 2, default: 0.00
      t.integer :amount_type
      t.boolean :is_deleted, default: :false

      t.timestamps
    end

    add_index :event_cancellation_plan_items, [:event_cancellation_plan_id], name: 'index_event_cancellation_plan_items_on_cancellation_plan_id'
  end
end
