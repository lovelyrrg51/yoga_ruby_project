require 'rails_helper'

RSpec.describe SpiritualPractice, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:sadhak_profile) }
    it { should have_many(:spiritual_practice_frequent_sadhna_type_associations).dependent(:destroy) }
    it { should have_many(:frequent_sadhna_types).through(:spiritual_practice_frequent_sadhna_type_associations) }
    it { should have_many(:spiritual_practice_physical_exercise_type_associations).dependent(:destroy) }
    it { should have_many(:physical_exercise_types).through(:spiritual_practice_physical_exercise_type_associations) }
    it { should have_many(:spiritual_practice_shivyog_teaching_associations).dependent(:destroy) }
    it { should have_many(:shivyog_teachings).through(:spiritual_practice_shivyog_teaching_associations) }
  end

  # describe "validations" do
  #   sadhak_profile = SadhakProfile.count > 0 ? SadhakProfile.last : SadhakProfile.create(first_name: "test", last_name: "test", date_of_birth: "1980-03-05", gender: "male", user_id: 98)
  #   subject {FactoryBot.build(:spiritual_practice, sadhak_profile_id: sadhak_profile.id)}
  #   it { should validate_uniqueness_of(:sadhak_profile_id).case_insensitive }
  # end

  it { should accept_nested_attributes_for(:frequent_sadhna_types) }
  it { should accept_nested_attributes_for(:physical_exercise_types) }
  it { should accept_nested_attributes_for(:shivyog_teachings) }
  it { should define_enum_for(:sadhana_frequency_days_per_week).with_values({daily: 0, weekly: 1, monthly: 2, only_during_shivir: 3}) }
end