require 'rails_helper'

RSpec.describe DigitalAsset, type: :model do
  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:collection).optional }
    it { should have_many(:purchased_digital_assets).dependent(:destroy) }
    it { should have_many(:users).through(:purchased_digital_assets) }
    it { should have_one(:asset_collection).class_name('Collection').with_foreign_key(:source_asset_id) }
    it { should have_many(:digital_assets).through(:asset_collection) }
    it { should have_many(:line_items).dependent(:destroy) }
    it { should have_many(:orders).through(:line_items) }
    it { should have_many(:asset_tag_mappings).dependent(:destroy) }
    it { should have_many(:asset_tags).through(:asset_tag_mappings) }
    it { should belong_to(:digital_asset_secret) }
    it { should have_many(:asset_group_mappings) }
    it { should have_many(:user_groups).through(:asset_group_mappings).source(:user_group) }
    it { should have_many(:event_type_digital_asset_associations) }
    it { should have_many(:event_types).through(:event_type_digital_asset_associations) }
    it { should have_many(:cannonical_event_digital_asset_associations) }
    it { should have_many(:cannonical_events).through(:cannonical_event_digital_asset_associations) }
  end

  it { should define_enum_for(:available_for).with_values(all_platforms: 0, web: 1, chrome_app: 2, window: 3) }

  describe "validations" do
    it { should validate_presence_of(:asset_name) }
    it { should validate_length_of(:asset_name).is_at_most(255) }
    it { should validate_presence_of(:expires_at) }
    it { should validate_presence_of(:published_on) }
    it { should validate_presence_of(:language) }
  end
end
