require 'rails_helper'

RSpec.describe EventCancellationPlan, type: :model do

  describe "associations" do

    it { should have_many(:event_cancellation_plan_items).dependent(:destroy)}
    it { should have_many(:events)}
    it { should have_many(:payment_refunds)}
  end

  describe "validations" do

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

  end

  describe 'default scope' do
    is_deleted = false
    it "should return collection whose is_deleated is false" do
      expect(is_deleted).to eq(subject.is_deleted)
    end
  end
end
