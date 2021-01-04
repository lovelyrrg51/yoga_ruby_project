module Api::V1
  class DbStateSerializer < ActiveModel::Serializer
    attributes :id, :country_id, :name
  end
end
