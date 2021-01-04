module Api::V1
  class TaxTypeSerializer < ActiveModel::Serializer
    attributes :id, :name
  end
end
