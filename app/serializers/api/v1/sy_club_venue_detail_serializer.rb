module Api::V1
  class SyClubVenueDetailSerializer < ActiveModel::Serializer
    attributes :id, :venue_type, :room_size, :windows_count, :fans_count, :doors_count, :room_color, :carpet_type, :yantras_count, :lighting_arrangement, :painting_in_room, :room_other_activities, :time
    
    #embed :ids
    has_one :sy_club
  end
end
