class CannonicalEvent < ApplicationRecord
  ALLOWED_EVENT_META_TYPES = %w[virtual mega live]

  has_many :event_prerequisites, foreign_key: :cannonical_event_id
  has_many :prerequisite_cannonical_events, through: :event_prerequisites,
    class_name: 'CannonicalEvent' # need to check this
  has_many :events
  has_many :cannonical_event_digital_asset_associations, dependent: :destroy
  has_many :digital_assets, through: :cannonical_event_digital_asset_associations

  validates :event_meta_type, presence: true,
    inclusion: { in: ALLOWED_EVENT_META_TYPES }
  validates :event_name, presence: true
end
