require 'rails_helper'

RSpec.describe DbState, type: :model do

  subject { create(:db_state, name: 'Test State') }

  describe "associations" do
    it { should belong_to(:country).class_name('DbCountry').with_foreign_key(:country_id) }
    it { should have_many(:cities).class_name('DbCity').with_foreign_key(:state_id).dependent(:destroy) }
    it { should have_many(:addresses).inverse_of(:db_state) }
  end

  describe "validations" do
    it { should validate_uniqueness_of(:name).scoped_to(:country_id).with_message('already exist in this state').case_insensitive }
  end

end
