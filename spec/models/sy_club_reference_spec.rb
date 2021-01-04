require 'rails_helper'

RSpec.describe SyClubReference, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:sy_club) }
    it { should belong_to(:sadhak_profile) }
  end

end