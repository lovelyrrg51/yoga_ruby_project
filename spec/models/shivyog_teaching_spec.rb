require 'rails_helper'

RSpec.describe ShivyogTeaching, type: :model do

  describe "associations" do
    it { should have_many(:spiritual_practice_shivyog_teaching_associations).dependent(:destroy) }
    it { should have_many(:spiritual_practices).through(:spiritual_practice_shivyog_teaching_associations) }
  end

  describe "validations" do
    it { should validate_uniqueness_of(:name).ignoring_case_sensitivity }
  end
end