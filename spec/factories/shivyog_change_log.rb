FactoryBot.define do
  factory(:shivyog_change_log) do
    attribute_name "status"
    change_loggable_id nil
    change_loggable_type "SyClub"
    deleted_at nil
    description nil
    value_after "enabled"
    value_before nil
    whodunnit nil
  end
end
