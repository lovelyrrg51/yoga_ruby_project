class DigitalAssetSecret < ApplicationRecord
  acts_as_paranoid

  has_one :digital_asset

  validates :asset_dl_url, :asset_file_name, :asset_url, presence: true
  validates :video_id, uniqueness: true
  validates_numericality_of :asset_file_size, greater_than: 0

  before_create :assign_video_id

  private

  def assign_video_id
    self.video_id = loop do
      _video_id = Utilities::UniqueKeyGenerator.generate
      break _video_id unless DigitalAssetSecret.exists?(video_id: _video_id)
    end
  end
end
