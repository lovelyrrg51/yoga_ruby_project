require 'rails_helper'

RSpec.describe Relation, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:sadhak_profile) }
    it { should belong_to(:user) }
  end
end
