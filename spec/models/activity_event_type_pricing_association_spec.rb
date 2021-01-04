require 'rails_helper'

RSpec.describe ActivityEventTypePricingAssociation, type: :model do
  describe "associations" do
    it { should belong_to :event }
    it { should belong_to :event_type_pricing }
  end
end
