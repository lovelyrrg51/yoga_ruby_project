require 'rails_helper'

RSpec.describe PgSyHdfcPayment, type: :model do

  describe "associations" do
    it { should belong_to(:user).optional }
    it { should belong_to(:event_order) }
    it { should belong_to(:hdfc_config).class_name('HdfcConfig').with_foreign_key('config_id') }
  end

  it do
    should define_enum_for(:status).with([:pending, :success, :failure])
  end

  describe "validations" do
    it { should validate_presence_of(:billing_name) }
    it { should validate_presence_of(:billing_address) }
    it { should validate_presence_of(:billing_address_state) }
    it { should validate_presence_of(:billing_address_country) }
    it { should validate_presence_of(:billing_phone) }
    it { should validate_presence_of(:billing_email) }
    it { should validate_presence_of(:billing_address_postal_code) }
    it { should validate_presence_of(:event_order_id) }
    it { should validate_numericality_of(:billing_phone)}
    describe 'billing_email' do
      it { should allow_value("email@addresse.gmail.com").for(:billing_email) }
      it { should_not allow_value("foo").for(:billing_email) }
    end
  end

end
