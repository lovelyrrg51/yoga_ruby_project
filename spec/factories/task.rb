FactoryBot.define do
  factory(:task) do
    email "pankaj@metadesign.org.in"
    final_block nil
    message nil
    opts nil
    start_block nil
    status "completed"
    t_config nil
    taskable_id 122
    taskable_type "User"
  end
end
