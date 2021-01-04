module Api::V1
  class EventOrderSadhakProfileSerializer < ActiveModel::Serializer
     attributes :id, :syid, :first_name, :last_name, :gender, :date_of_birth, :mobile, :phone, :is_mobile_verified, :email, :is_email_verified, :profile_completeness, :is_approved_for_mega_events,  :is_approved_for_virtual_events, :username, :profile_photo_status, :photo_id_status, :address_proof_status
      
      #embed :ids
      has_many :events
  end
end
