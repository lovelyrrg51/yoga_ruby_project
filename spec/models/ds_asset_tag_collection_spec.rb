require 'rails_helper'

RSpec.describe DsAssetTagCollection, type: :model do

  describe "associations" do
    it { should belong_to(:ds_asset_tag) }
  end
end

