module Api::V1
  class UnapprovedSadhakProfileSerializer < ActiveModel::Serializer
    attributes :id, :syid, :first_name, :last_name, :middle_name, :gender, :date_of_birth, :mobile, :phone, :is_mobile_verified, :email, :is_email_verified, :occupation_type, :profile_completeness, :is_approved_for_mega_events,  :is_approved_for_virtual_events, :username, :profile_photo_status, :photo_id_status, :address_proof_status, :relationship_type
    
    #embed :ids
    has_one :address, include: true
    has_one :advance_profile, include: true
    
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
