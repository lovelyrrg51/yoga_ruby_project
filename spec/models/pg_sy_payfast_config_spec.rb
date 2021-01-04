require 'rails_helper'

RSpec.describe PgSyPayfastConfig, type: :model do

  it { should belong_to(:payment_gateway).dependent(:destroy)}

  describe "validations" do
    it { should validate_presence_of(:user_name) }
    it { should validate_presence_of(:alias_name) }
    it { should validate_presence_of(:merchant_id) }
    it { should validate_presence_of(:merchant_key) }
    it { should validate_presence_of(:payment_gateway) }
    it { should validate_presence_of(:country_id) }
    it { should validate_presence_of(:tax_amount) }
    it { should validate_numericality_of(:tax_amount).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100)}
    it { should validate_uniqueness_of(:alias_name) }
  end

  it do
    should define_enum_for(:pdt).with_values({disabled: 1, enabled: 2})
  end

  describe 'aasm states' do
    it { should have_state(:disabled) }
  end

  describe 'default scope' do
    is_deleted = false
    it "should return collection whose is_deleated is false" do
      expect(is_deleted).to eq(subject.is_deleted)
    end
  end

end
