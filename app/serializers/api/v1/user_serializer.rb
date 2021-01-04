module Api::V1
  class UserSerializer < ActiveModel::Serializer
    attributes :id, :email, :name, :super_admin, :digital_store_admin, :group_admin, :last_name, :spree_api_key , :event_admin, :is_mobile_verified, :is_email_verified, :contact_number, :username, :photo_approval_admin, :country_id, :date_of_birth, :gender, :club_admin, :authentication_token, :india_admin, :sadhak_profile_id, :registration_center_ids, :sadhak_profile_ids
  
    #embed :ids
    has_one :sadhak_profile, serializer: SadhakProfileSessionSerializer, include: true
    # has_many :user_groups
    # has_many :purchased_digital_assets
    # has_many :ticket_groups
    has_many :registration_centers
    has_many :sadhak_profiles
  #   has_many :registered_events
  
  #   def sadhak_profiles#_ids
  # #     if current_user
  #       object.relations.pluck(:sadhak_profile_id)
  # #     end
  #   end
  end
end
