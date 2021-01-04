class CreateEventCostEstimations < ActiveRecord::Migration
  def change
    create_table :event_cost_estimations do |t|
      t.string :name
      t.decimal :budget, precision: 10, scale: 2
      t.references :event, index: true
      t.foreign_key :events, dependent: :delete

      t.timestamps
    end
  end
end
