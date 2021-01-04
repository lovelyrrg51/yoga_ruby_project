module Api::V1
  class SyClubSadhakProfileAssociationSerializer < ActiveModel::Serializer
    attributes :id, :status, :club_joining_date, :guest_email, :sadhak_profile_id, :sy_club_id, :sy_club_user_role_id, :sy_club_validity_window_id, :first_name, :last_name
  
    def first_name
      object.try(:sadhak_profile).try(:first_name)
    end
  
    def last_name
      object.try(:sadhak_profile).try(:last_name)
    end
  end
end
