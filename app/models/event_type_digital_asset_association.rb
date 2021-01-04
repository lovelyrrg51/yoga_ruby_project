class EventTypeDigitalAssetAssociation < ApplicationRecord
  belongs_to :event_type
  belongs_to :digital_asset

  validates :event_type, :digital_asset, presence: true

  scope :event_type_id, ->(event_type_id) { where(event_type_id: event_type_id) }
  scope :digital_assest_id, ->(digital_assest_id) { where(digital_assest_id: digital_assest_id) }

  def self.preloaded_data
    EventTypeDigitalAssetAssociation.includes(:event_type, :digital_asset)
  end
end
