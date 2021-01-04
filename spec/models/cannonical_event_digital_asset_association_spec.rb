require 'rails_helper'
RSpec.describe CannonicalEventDigitalAssetAssociation, type: :model do
  describe "associations" do
    it { should belong_to :digital_asset }
    it { should belong_to :cannonical_event }
  end
end
