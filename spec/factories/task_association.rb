FactoryBot.define do
  factory(:task_association) do
    child_task_id 2
    parent_task_id 1
  end
end
