FactoryBot.define do
  factory(:forum_attendance) do
    deleted_at nil
    forum_attendance_detail { build :forum_attendance_detail }
    is_attended true
    is_current_forum_member true
    last_updated_by 112882
    sadhak_profile { build :sadhak_profile }
    sy_club_member { build :sy_club }
  end
end
