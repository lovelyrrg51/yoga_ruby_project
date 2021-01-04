require 'rails_helper'

RSpec.describe ShivyogJourney, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:sadhak_profile) }
  end

  describe "validations" do
    it { should validate_uniqueness_of(:sadhak_profile_id) }
  end

end