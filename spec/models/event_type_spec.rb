require 'rails_helper'

RSpec.describe EventType, type: :model do
  describe "associations" do
    it { should belong_to(:reference_event).class_name('Event').with_foreign_key('reference_event_id')}
    it { should have_many(:events)}
    it { should have_many(:event_type_digital_asset_associations)}
    it { should have_many(:digital_assets).through(:event_type_digital_asset_associations)}
    it { should have_many(:digital_asset_secrets).through(:digital_assets)}
    it { should have_many(:sy_club_event_type_associations)}
    it { should have_many(:sy_clubs).through(:sy_club_event_type_associations)}
    it { should have_many(:event_type_pricings).dependent(:destroy)}
  end

  describe "validations" do

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:event_meta_type) }
    it { should validate_uniqueness_of(:name).ignoring_case_sensitivity }
  end

  it do
    should define_enum_for(:event_meta_type).with_values({virtual: 0, mega: 1, live: 2})
  end
end
