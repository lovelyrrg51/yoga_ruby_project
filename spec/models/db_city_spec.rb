require 'rails_helper'

RSpec.describe DbCity, type: :model do

  describe "associations" do
    it { should belong_to(:country).class_name('DbCountry').with_foreign_key(:country_id) }
    it { should belong_to(:state).class_name('DbState').with_foreign_key(:state_id) }
    it { should have_many(:addresses).with_foreign_key(:city_id)}
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:state_id,:country_id).with_message('This state is already exists.').case_insensitive }
  end

end
