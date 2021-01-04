require 'rails_helper'
RSpec.describe AssetTag, type: :model do
  describe "associations" do
    it { should belong_to :digital_asset }
    it { should belong_to :tag_collection }
    it { should have_many :asset_tag_mappings}
    it { should have_many(:digital_assets).through(:asset_tag_mappings)}
  end
end
