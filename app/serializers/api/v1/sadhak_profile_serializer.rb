module Api::V1
  class SadhakProfileSerializer < ActiveModel::Serializer
    attributes :id, :syid, :first_name, :last_name, :middle_name, :gender, :date_of_birth, :mobile, :phone, :is_mobile_verified, :email, :is_email_verified, :occupation_type, :profile_completeness, :is_approved_for_mega_events,  :is_approved_for_virtual_events, :username, :profile_photo_status, :photo_id_status, :address_proof_status, :status, :is_under_age, :created_at, :name_of_guru, :marital_status, :spiritual_org_name, :active_club_ids, :active_forum_name, :expiration_date, :board_member_position, :board_member_forum_name

    #embed :ids
    has_one :address, include: true
    has_one :doctors_profile, include: true
    has_many :other_spiritual_associations, include: true
    has_one :professional_detail, include: true
    has_one :advance_profile, include: true
    has_one :spiritual_practice, include: true
    has_one :spiritual_journey, include: true
    has_one :aspects_of_life, include: true
    has_one :medical_practitioners_profile
    has_many :relations
    has_many :users
    has_many :events
    has_many :joined_clubs
    has_many :sy_clubs
    has_one :sadhak_seva_preference

    #embed :ids
    has_one :user

    # Return relation with current user
    def relationship_type
      if current_user
        if object.user == current_user
          return "self"
        end
        # Fetch relation of current user with this sadhak profile
        relation = object.relations.find{|r| r.user_id == current_user.id}
        return relation.try(:relationship_type)
      else
        return nil
      end
    end
  end
end
