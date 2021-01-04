class RemoveColumnFromTask < ActiveRecord::Migration
  def change
    remove_column :tasks, :parent_task_id, :integer
  end
end
