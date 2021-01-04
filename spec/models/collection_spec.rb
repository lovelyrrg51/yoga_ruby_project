require 'rails_helper'

RSpec.describe Collection, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should have_many(:digital_assets).dependent(:destroy).inverse_of(:collection) }
    it { should have_many(:episodes).dependent(:destroy).inverse_of(:collection).class_name(DigitalAsset.name) }
    it { should have_many(:sadhak_asset_access_associations) }
    it { should belong_to(:source_asset).class_name(DigitalAsset.name).with_foreign_key(:source_asset_id).optional }
  end

  describe "validations" do
    it { should validate_presence_of(:collection_name) }
    it { should validate_length_of(:collection_name).is_at_most(255) }
    # context "when collection type is farmer" do
    #   subject { Collection.new(collection_type: "farmer") }
    #   # subject {FactoryBot.build(:collection)}
    #   it { should validate_length_of(:collection_name).is_at_least(1).with_message("are required. Please add episodes.") }
    # end
    context "when collection type is not farmer" do
      subject { Collection.new(collection_type: "forum") }
      it { should_not validate_length_of(:collection_name).is_at_least(1).with_message("are required. Please add episodes.") }
    end
  end

  it do
    should define_enum_for(:collection_type).with_values({forum: 0, farmer: 1, shivir: 2})
  end
end
