module Api::V1
  class DbCitySerializer < ActiveModel::Serializer
    attributes :id, :state_id, :country_id, :name
  end
end
