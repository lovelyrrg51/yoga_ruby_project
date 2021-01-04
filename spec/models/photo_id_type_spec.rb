require 'rails_helper'

RSpec.describe PhotoIdType, type: :model do

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(3) }
    it { should validate_uniqueness_of(:name).ignoring_case_sensitivity }
  end

end
