module Api::V1
  class WpUserSerializer < ActiveModel::Serializer
    attributes :id, :email, :name, :super_admin, :digital_store_admin, :group_admin, :last_name , :event_admin, :is_mobile_verified, :is_email_verified, :contact_number, :username, :photo_approval_admin, :country_id, :date_of_birth, :gender, :club_admin, :authentication_token, :india_admin
  
    #embed :ids
    has_one :sadhak_profile, serializer: WpSadhakProfileSerializer, include: true
  end
end
