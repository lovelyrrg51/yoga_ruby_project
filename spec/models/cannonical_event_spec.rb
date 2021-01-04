require 'rails_helper'
RSpec.describe CannonicalEvent, type: :model do

  describe "validations" do
    it { should validate_presence_of(:event_meta_type) }
    it { should validate_inclusion_of(:event_meta_type).in_array(["virtual", "mega", "live"]) }
    it { should validate_presence_of(:event_name) }
  end

  describe "associations" do
    it { should have_many(:event_prerequisites).with_foreign_key(:cannonical_event_id) }
    it { should have_many(:prerequisite_cannonical_events).through(:event_prerequisites).class_name('CannonicalEvent') }
    it { should have_many :events }
    it { should have_many(:cannonical_event_digital_asset_associations).dependent(:destroy) }
    it { should have_many(:digital_assets).through(:cannonical_event_digital_asset_associations) }
  end
end
