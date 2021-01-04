require 'rails_helper'

RSpec.describe DbCountry, type: :model do

  subject { create(:db_country, name: 'Test Country') }

  describe "associations" do
    it { should have_many(:cities).class_name('DbCity').with_foreign_key(:country_id).dependent(:destroy) }
    it { should have_many(:states).class_name('DbState').with_foreign_key(:country_id).dependent(:destroy) }
    it { should have_many(:addresses).inverse_of(:db_country) }
  end

  # describe "validations" do
  #   it { should validate_presence_of(:name) }
  #   it { should validate_uniqueness_of(:name).case_insensitive }
  # end

end
