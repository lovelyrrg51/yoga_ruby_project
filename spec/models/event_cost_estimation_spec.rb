require 'rails_helper'

RSpec.describe EventCostEstimation, type: :model do

  describe "associations" do
    it { should belong_to(:event)}
  end

  describe "validations" do

    it { should validate_presence_of(:budget) }
    it { should validate_presence_of(:event_id) }
    it { should validate_numericality_of(:budget) }

  end
end
