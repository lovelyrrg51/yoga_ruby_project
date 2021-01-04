require 'rails_helper'

RSpec.describe AspectsOfLife, type: :model do
  let(:aspect_of_life) { Class.new }

  it { is_expected.to act_as_paranoid }
  describe "associations" do
    it { should belong_to :sadhak_profile }
    it { should have_many(:aspect_feedbacks).dependent(:destroy) }
  end

  describe "set constants" do
    before { stub_const("#{described_class}", aspect_of_life) }
  	it "REQUIRED_FIELD should eq [:aspect_feedbacks]" do
    	expect(described_class::REQUIRED_FIELD).to eq([:aspect_feedbacks])
    end
  end

  # it { should validate_uniqueness_of(:sadhak_profile_id) }
  it { should accept_nested_attributes_for(:aspect_feedbacks).allow_destroy(true) }
end
