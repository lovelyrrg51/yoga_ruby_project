class CreateTaskAssociations < ActiveRecord::Migration
  def change
    create_table :task_associations do |t|
      t.integer :parent_task_id
      t.integer :child_task_id

      t.timestamps
    end
  end
end
