module Api::V1
  class ForumAttendanceSerializer < ActiveModel::Serializer
    attributes :id, :is_attended, :is_current_forum_member, :sadhak_profile_id, :sy_club_member_id, :forum_attendance_detail_id, :syid, :full_name
  
    def syid
      object.try(:sadhak_profile).try(:syid)
    end
  
    def full_name
      object.try(:sadhak_profile).try(:full_name)
    end
  end
end
