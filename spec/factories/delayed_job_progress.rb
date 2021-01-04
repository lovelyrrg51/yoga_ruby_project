FactoryBot.define do
  factory(:delayed_job_progress) do
    delayed_job_progressable_id nil
    delayed_job_progressable_type nil
    deleted_at nil
    last_error nil
    progress_current 42.9190817397702
    progress_max 100.0
    progress_stage "ToFactory: RubyParser exception parsing this attribute"
    result nil
    status "processing"
    user_id 122
  end
end
