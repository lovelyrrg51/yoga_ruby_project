require 'rails_helper'

RSpec.describe SeatingCategory, type: :model do

  describe "associations" do
    it { should have_many(:event_seating_category_associations) }
  end

  describe "validations" do
    it { should validate_presence_of(:category_name) }
    it { should validate_length_of(:category_name).is_at_most(255) }
    it { should validate_uniqueness_of(:category_name).ignoring_case_sensitivity }
  end
end