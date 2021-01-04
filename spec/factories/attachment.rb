FactoryBot.define do
  factory(:attachment) do
    attachable_id 0
    attachable_type "Event"
    content nil
    deleted_at nil
    file_size "37"
    file_type "application/pdf"
    is_secure false
    name "unix_commands (1).pdf"
    s3_bucket "syportalattachments"
    s3_path "ToFactory: RubyParser exception parsing this attribute"
    s3_url "ToFactory: RubyParser exception parsing this attribute"
  end
end
