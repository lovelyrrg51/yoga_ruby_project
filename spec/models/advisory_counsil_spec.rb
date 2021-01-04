require 'rails_helper'
RSpec.describe AdvisoryCounsil, type: :model do
  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to :sadhak_profile }
    it { should belong_to :sy_club }
  end
end
