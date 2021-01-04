module Api::V1
  class VenueTypeSerializer < ActiveModel::Serializer
    attributes :id, :name
  end
end
