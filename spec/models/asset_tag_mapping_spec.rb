require 'rails_helper'
RSpec.describe AssetTagMapping, type: :model do
  describe "associations" do
    it { should belong_to :digital_asset }
    it { should belong_to :asset_tag }
  end
end
