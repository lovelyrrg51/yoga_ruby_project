require 'rails_helper'

RSpec.describe Address, type: :model do
  let(:address) { Class.new }
  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to :addressable }
    it {should belong_to(:db_country).class_name('DbCountry').optional
      .with_foreign_key('country_id').inverse_of(:addresses) }
    it { should belong_to(:db_state).class_name('DbState').optional
      .with_foreign_key('state_id').inverse_of(:addresses) }
    it { should belong_to(:db_city).class_name('DbCity').optional
      .with_foreign_key('city_id').inverse_of(:addresses) }
  end

  describe "delegate" do
    it { should delegate_method(:name).to(:db_country).with_prefix(:country).allow_nil }
    it { should delegate_method(:currency_code).to(:db_country).with_prefix(:country).allow_nil }
    it { should delegate_method(:telephone_prefix).to(:db_country).with_prefix(:country).allow_nil }
    it { should delegate_method(:ISO2).to(:db_country).with_prefix(:country).allow_nil }
  end

  describe "set constants" do
    before { stub_const("#{described_class}", address) }
    it { expect(described_class::REQUIRED_FIELD).to eq([:first_line, :state_id, :city_id, :postal_code, :country_id]) }
  end
end
