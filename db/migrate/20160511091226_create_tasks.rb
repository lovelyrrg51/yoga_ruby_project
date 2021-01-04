class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :parent_task_id
      t.string :taskable_type
      t.integer :taskable_id
      t.integer :status
      t.text :message

      t.timestamps
    end
  end
end
