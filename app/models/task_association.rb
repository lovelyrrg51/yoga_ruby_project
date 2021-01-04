class TaskAssociation < ApplicationRecord
  belongs_to :parent_task, class_name: 'Task', foreign_key: 'parent_task_id'
  belongs_to :child_task, class_name: 'Task', foreign_key: 'child_task_id'
end
