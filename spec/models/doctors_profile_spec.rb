require 'rails_helper'

RSpec.describe DoctorsProfile, type: :model do
  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:sadhak_profile) }
    it { should belong_to(:practice_state).class_name('DbState').with_foreign_key(:practice_state_id) }
    it { should belong_to(:license_state).class_name('DbState').with_foreign_key(:license_state_id) }
    it { should belong_to(:practice_country).class_name('DbCountry').with_foreign_key(:practice_country_id) }
    it { should belong_to(:license_country).class_name('DbCountry').with_foreign_key(:license_country_id) }
  end

  it { should define_enum_for(:license_status).with_values(%w(active expired)) }
  
  describe "validations" do
    # it { should validate_uniqueness_of(:sadhak_profile_id) }
    it { should validate_presence_of(:medical_school) }
    it { should validate_presence_of(:education_country_id) }
    it { should validate_presence_of(:year_of_graduation) }
    it { should validate_presence_of(:area_of_speciality) }
    it { should validate_presence_of(:sub_speciality) }
    it { should validate_presence_of(:license_status) }
    it { should validate_presence_of(:license_state_id) }
    it { should validate_presence_of(:license_country_id) }
    it { should validate_presence_of(:primary_work_setting) }
    it { should validate_presence_of(:practice_place) }
    it { should validate_presence_of(:practice_state_id) }
    it { should validate_presence_of(:practice_country_id) }
    it { should validate_presence_of(:practice_years) }
    it { should validate_presence_of(:hospital_affiliations) }
    it { should validate_presence_of(:professional_publications) }
    it { should validate_presence_of(:honors_and_awards) }
  end
end
