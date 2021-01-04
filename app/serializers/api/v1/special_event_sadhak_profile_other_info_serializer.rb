module Api::V1
  class SpecialEventSadhakProfileOtherInfoSerializer < ActiveModel::Serializer
    attributes :id, :sadhak_profile_id, :event_order_line_item_id, :event_id
  
    #embed :ids
    has_many :sadhak_profiles
  end
end
