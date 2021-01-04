module Api::V1
  class ChromeUserBasicDetailSerializer < ActiveModel::Serializer
    attributes :id, :syid, :forum_name, :board_member_position, :full_name, :email, :sy_club_id, :sy_club_address, :attended_event_types, :has_attended_farmer_shivir, :can_view_shivir_collection, :can_view_shivir_collection
    
    def syid
      object.try(:sadhak_profile).try(:syid)
    end
  
    def forum_name
      object.try(:sadhak_profile).try(:sy_clubs).try(:first).try(:name) || object.try(:sadhak_profile).try(:advisory_counsil).try(:sy_club).try(:name)
    end
  
    def board_member_position
      object.try(:sadhak_profile).try(:board_member_position) || (object.try(:sadhak_profile).try(:advisory_counsil).present? ? "Advisory Council" : "")
    end
  
    def full_name
      object.try(:sadhak_profile).try(:full_name)
    end
  
    def email
      object.try(:sadhak_profile).try(:email)
    end
  
    def sy_club_id
      object.try(:sadhak_profile).try(:sy_clubs).try(:first).try(:id)
    end
  
    def sy_club_address
      object.try(:sadhak_profile).try(:sy_clubs).try(:first).try(:address).try(:full_address)
    end

    def attended_event_types
      object.try(:sadhak_profile).try(:attended_event_types)
    end

    def has_attended_farmer_shivir
      object.try(:sadhak_profile).try(:has_attended_farmer_shivir)
    end
  
    def can_view_shivir_collection
      object.try(:sadhak_profile).try(:can_view_shivir_collection)
    end
  
  end
end
