module Api::V1
  class SyClubSerializer < ActiveModel::Serializer
    attributes :id, :name, :club_level, :members_count, :status, :email, :contact_details, :other_activity, :cultural_activities, :min_members_count, :content_type, :active_members_count, :has_board_members_paid
    
    #embed :ids
      has_one :address, include: true
      has_one :sy_club_digital_arrangement_detail
      has_one :sy_club_venue_detail
      has_many :events
      has_many :sadhak_profiles
      has_many :event_types
      has_many :sy_club_sadhak_profile_associations, include: true
  end
end
