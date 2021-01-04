class EventType < ApplicationRecord
  validates :name, uniqueness: true, presence: true, case_sensitive: false
  validates :event_meta_type, presence: true

  enum event_meta_type: {
    virtual: 0,
    mega: 1,
    live: 2
  }

  has_many :events
  has_many :collection_event_type_associations
  has_many :event_type_digital_asset_associations
  has_many :digital_assets, through: :event_type_digital_asset_associations
  has_many :digital_asset_secrets, through: :digital_assets
  has_many :sy_club_event_type_associations
  has_many :sy_clubs, through: :sy_club_event_type_associations
  has_many :event_type_pricings, dependent: :destroy
  belongs_to :reference_event, class_name: 'Event', foreign_key: :reference_event_id

  scope :event_type_name, ->(event_type_name) { where("name ILIKE ?", "%#{event_type_name}%") }

end
