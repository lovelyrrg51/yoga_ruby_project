module Api::V1
  class AddressProofTypeSerializer < ActiveModel::Serializer
    attributes :id, :name
  end
end
