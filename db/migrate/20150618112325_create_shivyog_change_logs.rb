class CreateShivyogChangeLogs < ActiveRecord::Migration
  def change
    create_table :shivyog_change_logs do |t|
      t.string :attribute_name
      t.string :value_before
      t.string :value_after
      t.string :description
      t.integer :change_loggable_id
      t.string :change_loggable_type

      t.timestamps
    end
  end
end
