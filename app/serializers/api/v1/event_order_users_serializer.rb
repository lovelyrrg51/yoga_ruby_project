module Api::V1
  class EventOrderUsersSerializer < ActiveModel::Serializer
    attributes :id, :email, :name, :super_admin, :digital_store_admin, :group_admin, :last_name, :spree_api_key ,:event_admin, :is_mobile_verified, :is_email_verified, :contact_number, :username, :photo_approval_admin, :country_id, :date_of_birth, :gender
  end
end
