class Chrome::Api::V1::SyClubAddressSerializer < ActiveModel::Serializer
  attributes :id, :country_id
  
  # embed :ids
  has_one :db_country, serializer: Chrome::Api::V1::DbCountrySerializer, include: true
end
