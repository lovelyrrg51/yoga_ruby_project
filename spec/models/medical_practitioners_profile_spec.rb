require 'rails_helper'

RSpec.describe MedicalPractitionersProfile, type: :model do
  it { is_expected.to act_as_paranoid }
  describe "associations" do
    it { should belong_to(:sadhak_profile)}
    it { should belong_to(:medical_practitioner_speciality_area)}
  end

  describe "validations" do
    it { should validate_uniqueness_of(:sadhak_profile_id).on(:create) }
  end

  it do
    should define_enum_for(:current_professional_role).with_values({physician: 0, therapist: 1, health_care_extender: 2, medical_student: 3, other: 4})
    should define_enum_for(:work_enviroment).with_values({academia: 0, administrator: 1, goverment_regular: 2, medical_director: 3, private_practice: 4, research: 5, retired_physican: 6, employed_physican: 7})
  end
end
