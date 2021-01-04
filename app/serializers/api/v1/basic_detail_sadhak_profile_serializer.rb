module Api::V1
  class BasicDetailSadhakProfileSerializer < ActiveModel::Serializer
    attributes :id, :syid, :first_name, :last_name, :middle_name, :gender, :date_of_birth, :mobile, :phone, :is_mobile_verified, :email, :is_email_verified, :occupation_type, :profile_completeness, :is_approved_for_mega_events,  :is_approved_for_virtual_events, :username, :profile_photo_status, :photo_id_status, :address_proof_status, :status, :is_under_age, :created_at, :name_of_guru, :marital_status, :spiritual_org_name, :user_id
  end
end
