require 'rails_helper'

RSpec.describe PhysicalExerciseType, type: :model do

  describe "associations" do
    it { should have_many(:spiritual_practice_physical_exercise_type_associations).dependent(:destroy) }
    it { should have_many(:spiritual_practices).through(:spiritual_practice_physical_exercise_type_associations) }
  end

  it { should validate_uniqueness_of(:name).ignoring_case_sensitivity }
end
