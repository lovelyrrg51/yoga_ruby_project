require 'rails_helper'

RSpec.describe EventDiscountPlanAssociation, type: :model do
  describe "associations" do
    it { should belong_to(:event)}
    it { should belong_to(:discount_plan)}
  end

  describe "validations" do
    # it { should validate_uniqueness_of(:event_id).scoped_to(:discount_plan_id) }
  end
end
