require 'rails_helper'

RSpec.describe SpecialEventSadhakProfileReference, type: :model do

  describe "associations" do
    it { should belong_to(:special_event_sadhak_profile_other_info) }
    it { should belong_to(:sadhak_profile) }
  end

  # describe "validations" do
  #   sadhak_profile = SadhakProfile.count > 0 ? SadhakProfile.last : SadhakProfile.create(first_name: "test", last_name: "test", date_of_birth: "1980-03-05", gender: "male", user_id: 98)
  #   subject { FactoryBot.build(:special_event_sadhak_profile_reference, sadhak_profile_id: sadhak_profile.id) }
  #   it { should validate_uniqueness_of(:sadhak_profile_id).scoped_to(:special_event_sadhak_profile_other_info_id).with_message('is already taken. Please use two different sadhak profiles for references.') }
  # end
end