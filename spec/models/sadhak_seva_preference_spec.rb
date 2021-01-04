require 'rails_helper'

RSpec.describe SadhakSevaPreference, type: :model do

  let(:sadhak_seva_preference) { Class.new }

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:sadhak_profile) }
  end

  describe "validations" do
    it { should validate_uniqueness_of(:sadhak_profile_id).on(:create) }
    context "when a seva_preference is other" do
      subject { SadhakSevaPreference.new(seva_preference: 'other') }
      it { should validate_presence_of(:other_seva_preference) }
    end
  end

  describe "enum" do
    it { should define_enum_for(:availability).with_values({before_2_hours: 1, during_breaks: 2, after_1_hour: 3}) }
    it { should define_enum_for(:seva_preference).with_values({hall: 1, catering: 2, car_park: 3, divine_shop: 4, shoe: 5, facilities: 6, registeration: 7, stage: 8, music: 9, queue_management: 10, other: 11}) }
  end

  describe "set constants" do
    before { stub_const("#{described_class}", sadhak_seva_preference) }
    it { expect(described_class::REQUIRED_FIELD).to eq([:seva_preference, :availability]) }
  end
end