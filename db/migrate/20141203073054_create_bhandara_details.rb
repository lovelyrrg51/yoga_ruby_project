class CreateBhandaraDetails < ActiveRecord::Migration
  def change
    create_table :bhandara_details do |t|
      t.decimal :budget, precision: 10, scale: 2
      t.integer :event_id
      
      t.foreign_key :events, dependent: :delete
      t.timestamps
    end
  end
end
