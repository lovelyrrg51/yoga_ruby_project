require 'rails_helper'

RSpec.describe Profession, type: :model do

  it { should have_many(:professional_details) }
  it { should validate_uniqueness_of(:name).ignoring_case_sensitivity }
end
