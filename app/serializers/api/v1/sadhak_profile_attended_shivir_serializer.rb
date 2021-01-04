module Api::V1
  class SadhakProfileAttendedShivirSerializer < ActiveModel::Serializer
    attributes :id, :shivir_name, :place, :month, :year
    
    #embed :ids
    has_one :sadhak_profile
  end
end
