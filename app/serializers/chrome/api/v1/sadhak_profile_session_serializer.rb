class Chrome::Api::V1::SadhakProfileSessionSerializer < ActiveModel::Serializer
  attributes :id, :syid, :first_name, :active_club_ids
  
  # embed :ids
  has_many :sy_clubs

end
