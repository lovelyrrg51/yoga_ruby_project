require 'rails_helper'

RSpec.describe VenueType, type: :model do

  describe "associations" do
    it { should have_many(:events)}
  end

  describe "validations" do

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }

  end

end
