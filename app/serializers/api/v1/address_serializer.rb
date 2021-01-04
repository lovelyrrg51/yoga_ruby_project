module Api::V1
  class AddressSerializer < ActiveModel::Serializer
    attributes :id, :first_line, :second_line, :postal_code, :addressable_id, :addressable_type, :lat, :lng, :city_id, :state_id, :country_id, :sadhak_profile_id, :other_city, :other_state
    
    #embed :ids
    has_one :db_city, include: true
    has_one :db_state, include: true
    has_one :db_country, include: true
  end
end
