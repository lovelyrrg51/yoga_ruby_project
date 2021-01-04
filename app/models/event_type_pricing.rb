class EventTypePricing < ApplicationRecord
  # Tier_1 = EventRegistrationFee
  # Tier_2 = EventRegistrationFeeWithForumMembership
  # Tier_3 = EventRegistrationFeeForMembersOfThisForum
  belongs_to :event_type
  has_many :activity_event_type_pricing_associations, dependent: :destroy
  has_many :events, through: :activity_event_type_pricing_associations

  # defining tier types
  def self.tier_types
    [['Tier_1', '50'], ['Tier_2', '60'], ['Tier_3', "0"]]
  end

end
