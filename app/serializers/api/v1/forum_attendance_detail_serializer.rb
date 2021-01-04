module Api::V1
  class ForumAttendanceDetailSerializer < ActiveModel::Serializer
    
    attributes :id, :conducted_on, :digital_asset_id, :sy_club_id, :edit_count, :venue, :attendance_percentage, :asset_name, :published_on, :is_editable
  
    def venue
      object.venue.present? ? object.venue : object.sy_club.try(:address).try(:full_address)
    end
  
    def conducted_on
      object.conducted_on.try(:strftime, "%d-%m-%Y %I:%M:%S %p")
    end
  
    def is_editable
      (Time.zone.now.to_date - object.created_at.to_date).to_i < FORUM_ATTENDANCE_EDITABLE_VALIDITY
    end
    
  end
end
