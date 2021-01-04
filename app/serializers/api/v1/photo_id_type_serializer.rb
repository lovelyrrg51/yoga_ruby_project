module Api::V1
  class PhotoIdTypeSerializer < ActiveModel::Serializer
    attributes :id, :name
  end
end
