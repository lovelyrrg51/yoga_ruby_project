FactoryBot.define do
  factory(:forum_attendance_detail) do
    conducted_on "2017-08-08T10:00 UTC"
    creator_id 112882
    deleted_at nil
    digital_asset { build :digital_asset }
    edit_count 1
    last_updated_by_id 112882
    sy_club_id 1030
    venue "Dwarka Delhi"
  end
end
