module Api::V1
  class SpiritualJourneySerializer < ActiveModel::Serializer
    attributes :id, :source_of_information, :reason_for_joining, :first_event_attended, :first_event_attended_year, :first_event_attended_month, :sadhak_profile_id, :alternative_source
  
    #embed :ids
    # has_one :sub_source_type, include: true
    has_one :source_info_type
  end
end
