class CollectionEventTypeAssociation < ApplicationRecord

  # Associations
  belongs_to :collection
  belongs_to :event_type
  has_many :digital_assets, through: :collection

  # Validations
  validates :sadhak_profile_ids, presence: true, on: :update

  # Custom Validations
  validate :validate_sadhak_profile_ids, on: :update

  # Delegates
  delegate :collection_name, to: :collection, allow_nil: true

  def validate_sadhak_profile_ids
    syids = (sadhak_profile_ids.try(:split, ",") || []).map(&:upcase)
    syids = syids.reject { |syid| syid.to_s.empty? } || []
    duplicate_syid = syids.detect{ |e| syids.count(e) > 1 }    

    if duplicate_syid.present?
      errors.add(:sadhak_profile_ids, "#{duplicate_syid} is duplicate.")
    else

      event_creater_user_ids = Event.pluck(:creator_user_id).uniq
      event_creater_sadhak_profile_syids = SadhakProfile.joins(:user).where(users: { id: event_creater_user_ids }).pluck(:syid)
      non_event_creater_syids = syids.select{ |syid| !event_creater_sadhak_profile_syids.include?(syid) }
      errors.add(:sadhak_profile_ids, "- #{non_event_creater_syids.join(',')}: not the Creator User(s) of any Event.") if non_event_creater_syids.present?

    end
  end

end
