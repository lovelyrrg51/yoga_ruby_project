require 'rails_helper'

RSpec.describe RegistrationCenterUser, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:registration_center) }
  end
end
