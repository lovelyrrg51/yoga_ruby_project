require 'rails_helper'

RSpec.describe EventRegistrationCenterAssociation, type: :model do
  describe "associations" do
    it { should belong_to(:event)}
    it { should belong_to(:registration_center)}
  end

  # describe "validations" do
  #   it { should validate_uniqueness_of(:registration_center_id).scoped_to(:event_id) }
  # end
end
