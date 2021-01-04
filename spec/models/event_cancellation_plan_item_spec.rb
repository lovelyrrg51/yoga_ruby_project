require 'rails_helper'

RSpec.describe EventCancellationPlanItem, type: :model do
  it { should belong_to(:event_cancellation_plan)}

  it { should validate_presence_of(:days_before) }
  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:event_cancellation_plan_id) }
  it { should validate_uniqueness_of(:days_before).scoped_to(:event_cancellation_plan_id) }

  describe 'default scope' do
    is_deleted = false
    it "should return collection whose is_deleated is false" do
      expect(is_deleted).to eq(subject.is_deleted)
    end
  end

  it do
    should define_enum_for(:amount_type).with_values({fixed: 0, percentage: 1})
  end

  describe 'aasm states' do
    it { should have_state(:fixed) }
  end
end
