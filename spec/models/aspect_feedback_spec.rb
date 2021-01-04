require 'rails_helper'

RSpec.describe AspectFeedback, type: :model do
  let(:aspect_feedback) { Class.new }
  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to :aspects_of_life }
  end

  it { should define_enum_for(:aspect_type).with_values(family_happiness: 0, relationship: 1, peace_of_mind: 2, career: 3, health: 4, finances: 5, sadhana_frequency: 6) }

  describe "set constants" do
    before { stub_const("#{described_class}", aspect_feedback) }
    it "FAMILY_HAPPINESS should eq 0" do
    	expect(described_class::FAMILY_HAPPINESS).to eq(0)
    end
    it 'RELATIONSHIP should eq 1' do
    	expect(described_class::RELATIONSHIP).to eq(1)
    end
    it "PEACE_OF_MIND should eq 2" do
    	expect(described_class::PEACE_OF_MIND).to eq(2)
    end
    it "CAREER should eq 3" do
    	expect(described_class::CAREER).to eq(3)
    end
    it "HEALTH should eq 4" do
    	expect(described_class::HEALTH).to eq(4)
    end
    it "FINANCES should eq 5" do
    	expect(described_class::FINANCES).to eq(5)
    end
    it "SADHANA_FREQUENCY should eq 6" do
    	expect(described_class::SADHANA_FREQUENCY).to eq(6)
    end

    it "VERY_BAD should eq 0" do
    	expect(described_class::VERY_BAD).to eq(0)
    end
    it "BAD should eq 1" do
    	expect(described_class::BAD).to eq(1)
    end
    it "NEUTRAL should eq 2" do
    	expect(described_class::NEUTRAL).to eq(2)
    end
    it "GOOD should eq 3" do
    	expect(described_class::GOOD).to eq(3)
    end
    it "EXCELLENT should eq 4" do
    	expect(described_class::EXCELLENT).to eq(4)
    end
  end
  # it { should validate_uniqueness_of(:aspect_type).scoped_to(:aspects_of_life_id) }
end
