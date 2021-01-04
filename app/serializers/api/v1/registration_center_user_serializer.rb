module Api::V1
  class RegistrationCenterUserSerializer < ActiveModel::Serializer
    attributes :id, :user_id, :registration_center_id
  end
end
