require 'rails_helper'

RSpec.describe PgSyPaypalConfig, type: :model do

  describe "associations" do
    it { should belong_to(:payment_gateway).dependent(:destroy)}
    it { should belong_to(:db_country).class_name('DbCountry').with_foreign_key('country_id')}
  end

  describe "validations" do
    subject {FactoryBot.build(:pg_sy_paypal_config)}
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:password) }
    it { should validate_presence_of(:signature) }
    it { should validate_presence_of(:alias_name) }
    it { should validate_presence_of(:payment_gateway) }
    it { should validate_uniqueness_of(:username) }
    it { should validate_uniqueness_of(:password) }
    it { should validate_uniqueness_of(:signature) }
    it { should validate_uniqueness_of(:alias_name) }
    it { should validate_uniqueness_of(:payment_gateway) }
  end

  describe 'delegate methods' do
    it { should delegate_method(:name).to(:db_country).with_prefix('country').allow_nil }
    it { should delegate_method(:currency_code).to(:db_country).with_prefix('country').allow_nil }
    it { should delegate_method(:ISO3).to(:db_country).with_prefix('country').allow_nil }
  end
end
