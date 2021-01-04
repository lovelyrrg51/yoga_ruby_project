class Collection < ApplicationRecord
  acts_as_paranoid

  validates :collection_name, presence: true, length: { maximum: 255 }
  validates :episodes, length: {
    minimum: 1,
    message: 'are required. Please add episodes.'
  }, if: :farmer?

  has_many :digital_assets, dependent: :destroy, inverse_of: :collection
  has_many :episodes, -> { order 'asset_order ASC' }, dependent: :destroy, inverse_of: :collection, class_name: 'DigitalAsset'
  belongs_to :source_asset, :class_name => 'DigitalAsset', :foreign_key => 'source_asset_id', optional: true
  accepts_nested_attributes_for :episodes, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :digital_assets, reject_if: :all_blank, allow_destroy: true

  scope :collection_name, ->(collection_name) { where("collection_name ILIKE ?", "%#{collection_name}%")}
  scope :id, ->(id) { where.not(id: id) }
  scope :collection_type, ->(collection_type) {where(collection_type: Collection.collection_types[collection_type.downcase] || 0)}

  enum collection_type: {forum: 0, farmer: 1, shivir: 2}
  has_many :sadhak_asset_access_associations
  accepts_nested_attributes_for :sadhak_asset_access_associations, reject_if: proc { |attributes|  attributes[:access_from_date].blank? || attributes[:access_to_date].blank?}, :allow_destroy => true

  has_one :collection_event_type_association
  accepts_nested_attributes_for :collection_event_type_association

  serialize :announcement_text, Array

  def valid_asset_ids
    self.digital_assets.select{|da| da.published_on <= Date.today and da.expires_at >= Date.today}.collect{|da| da.id}
  end

  def update_assets_order(assets_order)
    ApplicationRecord.transaction do
      assets_order.each do |asset, order|
        puts "#{asset} #{order}"
        episodes.find{|episode| episode.id.to_s == asset}.update!(asset_order: order)
      end
    end
  end

  private
  def execute_before_save
    if self.source_asset.present? and !self.source_asset.is_collection
      errors.add(:source_asset_id, 'Source asset must be a collection.')
      return false
    end
  end

end
