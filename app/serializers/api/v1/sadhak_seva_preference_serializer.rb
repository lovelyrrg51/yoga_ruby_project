module Api::V1
  class SadhakSevaPreferenceSerializer < ActiveModel::Serializer
    attributes :id, :voluntary_organisation, :seva_preference, :other_seva_preference, :availability, :sadhak_profile_id, :expertise
  end
end
