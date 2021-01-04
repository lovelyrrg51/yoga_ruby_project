require 'rails_helper'

RSpec.describe SpiritualJourney, type: :model do

  let(:spiritual_journey) { Class.new }

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:sadhak_profile) }
    it { should belong_to(:sub_source_type) }
    it { should belong_to(:source_info_type) }
  end

  describe "validations" do
    sadhak_profile = SadhakProfile.count > 0 ? SadhakProfile.last : SadhakProfile.create(first_name: "test", last_name: "test", date_of_birth: "1980-03-05", gender: "male", user_id: 98)
    subject {FactoryBot.build(:spiritual_journey, sadhak_profile_id: sadhak_profile.id)}
    # it { should validate_uniqueness_of(:sadhak_profile_id) }
    it { should validate_presence_of(:source_info_type) }
  end

  describe "set constants" do
    before { stub_const("#{described_class}", spiritual_journey) }
    it { expect(described_class::REQUIRED_FIELD).to eq([:source_info_type_id]) }
  end
end