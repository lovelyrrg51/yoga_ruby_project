require 'rails_helper'

RSpec.describe EventDigitalAssetAssociation, type: :model do

  describe "associations" do
    it { should belong_to(:event).inverse_of(:event_digital_asset_associations)}
    it { should belong_to(:digital_asset)}
  end
end
