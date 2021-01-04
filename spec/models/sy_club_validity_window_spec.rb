require 'rails_helper'

RSpec.describe SyClubValidityWindow, type: :model do

  describe "associations" do
    it { should belong_to(:sy_club) }
    it { should have_many(:sy_club_sadhak_profile_associations) }
    it { should have_many(:sadhak_profiles).through(:sy_club_sadhak_profile_associations) }
  end
end