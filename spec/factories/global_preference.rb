FactoryBot.define do
  factory(:global_preference) do
    alias_name "Event Summay Report"
    group_name "Event"
    input_type "tagsinput"
    is_deleted false
    key "event_summary_report_email"
    val "ToFactory: RubyParser exception parsing this attribute"
  end
end
