module Api::V1
  class OtherSpiritualAssociationSerializer < ActiveModel::Serializer
    attributes :id, :organization_name, :association_description, :associated_since_year, :associated_since_month, :duration_of_practice, :sadhak_profile_id
  end
end
