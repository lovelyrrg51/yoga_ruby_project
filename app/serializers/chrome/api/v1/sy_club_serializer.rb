class Chrome::Api::V1::SyClubSerializer < ActiveModel::Serializer
  attributes :id, :name, :members_count, :min_members_count, :content_type, :active_members_count, :has_board_members_paid

  # embed :ids
  has_one :address, serializer: Chrome::Api::V1::SyClubAddressSerializer, include: true
  has_many :sy_club_sadhak_profile_associations, serializer: Chrome::Api::V1::SyClubSadhakProfileAssociationSerializer, include: true

end
