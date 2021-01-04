require 'rails_helper'

RSpec.describe DiscountPlan, type: :model do
  describe "associations" do
    it { should have_many(:event_discount_plan_associations).dependent(:destroy) }
    it { should have_many(:events).through(:event_discount_plan_associations).validate(false) }
  end

  it { should define_enum_for(:discount_type).with_values(percentage: 1, fixed: 2) }
  
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:discount_amount) }
    it { should validate_uniqueness_of(:name) }
    # it { should validate_numericality_of(:discount_amount).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
  end
end
