require 'rails_helper'

RSpec.describe EventTypePricing, type: :model do
  describe "associations" do
    it { should belong_to(:event_type)}
    it { should have_many(:activity_event_type_pricing_associations).dependent(:destroy)}
    it { should have_many(:events).through(:activity_event_type_pricing_associations)}
  end
end
