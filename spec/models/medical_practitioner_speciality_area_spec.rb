require 'rails_helper'

RSpec.describe MedicalPractitionerSpecialityArea, type: :model do
  it { should have_many(:medical_practitioners_profile)}

  it { should validate_uniqueness_of(:name).ignoring_case_sensitivity }

  describe '.medical_practitioner_speciality_area_name' do
    let!(:record_1) { create :medical_practitioner_speciality_area, name: 'example' }
    let!(:record_2) { create :medical_practitioner_speciality_area, name: 'test' }

    subject { described_class.medical_practitioner_speciality_area_name('test') }

    its(:size) { should be 1 }
    it { is_expected.not_to include record_1 }
    it { is_expected.to include record_2 }
  end
end
