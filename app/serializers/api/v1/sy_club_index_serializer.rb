module Api::V1
  class SyClubIndexSerializer < ActiveModel::Serializer
    attributes :id, :name, :status
  end
end
