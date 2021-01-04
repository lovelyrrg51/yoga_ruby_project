class Chrome::Api::V1::CurrentUserSerializer < ActiveModel::Serializer
  attributes :id, :super_admin, :username, :club_admin, :india_admin

  # embed :ids
  has_one :sadhak_profile, serializer: Chrome::Api::V1::SadhakProfileSessionSerializer, include: true
end
