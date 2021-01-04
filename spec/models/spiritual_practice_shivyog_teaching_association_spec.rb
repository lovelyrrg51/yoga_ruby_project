require 'rails_helper'

RSpec.describe SpiritualPracticeShivyogTeachingAssociation, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:spiritual_practice) }
    it { should belong_to(:shivyog_teaching) }
  end
end