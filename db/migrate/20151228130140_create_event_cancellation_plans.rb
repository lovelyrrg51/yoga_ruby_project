class CreateEventCancellationPlans < ActiveRecord::Migration
  def change
    create_table :event_cancellation_plans do |t|
      t.string :name
      t.boolean :is_deleted, default: :false

      t.timestamps
    end
  end
end
