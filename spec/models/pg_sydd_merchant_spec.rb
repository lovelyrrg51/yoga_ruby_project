require 'rails_helper'

RSpec.describe PgSyddMerchant, type: :model do

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:domain) }
    it { should validate_presence_of(:public_key) }
    it { should validate_presence_of(:sms_limit) }
    it { should validate_presence_of(:private_key) }
    it { should validate_presence_of(:email) }
    it { should validate_length_of(:email).is_at_most(255) }
    it { should validate_numericality_of(:sms_limit) }
    describe 'email' do
      it { should allow_value("email@address.gmail.com").for(:email) }
      it { should_not allow_value("foo").for(:email) }
    end
  end

end
