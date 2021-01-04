class SadhakAssetAccessAssociation < ApplicationRecord
  belongs_to :collection
  scope :access_from_date, lambda {|access_from_date| where('access_from_date <= ?', access_from_date) }
  scope :access_to_date, lambda {|access_to_date| where('access_to_date >= ?', access_to_date) }
  scope :live_shivir_episode_accesses, -> {joins(:collection => [:digital_assets]).where(collections: { collection_type: Collection.collection_types['farmer']}).where("digital_assets.published_on <= :current_date AND digital_assets.expires_at >= :current_date", {current_date: Date.today} ).access_from_date(Date.today).access_to_date(Date.today)}

  after_initialize :after_initialize
  def after_initialize
    self.access_from_date ||= Date.today if new_record?
    self.access_to_date ||= Date.today if new_record?
  end
end
