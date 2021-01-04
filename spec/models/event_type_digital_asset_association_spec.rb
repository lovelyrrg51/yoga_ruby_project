require 'rails_helper'

RSpec.describe EventTypeDigitalAssetAssociation, type: :model do
  describe "associations" do
    it { should belong_to(:event_type)}
    it { should belong_to(:digital_asset)}
  end

  describe "validations" do

    it { should validate_presence_of(:event_type) }
    it { should validate_presence_of(:digital_asset) }

  end

   #scope
  describe 'Return Event Type Id' do
    event_type = FactoryBot.build_stubbed(:event_type)
    subject = FactoryBot.build_stubbed(:event_type_digital_asset_association, event_type: event_type)
    it "should match event type id" do
      expect(subject.event_type_id).to be(event_type.id)
    end
    it "should not match event type id" do
      event_type_id = 2
      expect(subject.event_type_id).to_not be(event_type_id)
    end
  end

  describe 'Return Digital Asset Id' do
    digital_asset = FactoryBot.build_stubbed(:digital_asset)
    subject = FactoryBot.build_stubbed(:event_type_digital_asset_association, digital_asset: digital_asset)
    it "should match digital asset id" do
      expect(subject.digital_asset_id).to be(digital_asset.id)
    end
    it "should not match digital asset id" do
      digital_asset_id = 2
      expect(subject.digital_asset_id).to_not be(digital_asset_id)
    end
  end
end
