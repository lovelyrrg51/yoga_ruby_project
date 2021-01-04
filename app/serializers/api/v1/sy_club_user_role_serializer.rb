module Api::V1
  class SyClubUserRoleSerializer < ActiveModel::Serializer
    attributes :id, :role_name
  end
end
