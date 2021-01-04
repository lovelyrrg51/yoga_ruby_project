require 'rails_helper'

RSpec.describe RegistrationCenter, type: :model do

  describe "associations" do
    it { should have_many(:event_registration_center_associations).dependent(:destroy) }
    it { should have_many(:events).through(:event_registration_center_associations) }
    it { should have_many(:registration_center_users).dependent(:destroy) }
    it { should have_many(:users).through(:registration_center_users) }
    it { should have_many(:sadhak_profiles).through(:users).source(:sadhak_profile) }
  end
end
