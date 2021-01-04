require 'rails_helper'

RSpec.describe PgSyPayfastPayment, type: :model do

  describe "associations" do
    it { should belong_to(:event_order)}
    it { should belong_to(:pg_sy_payfast_config).class_name('PgSyPayfastConfig').with_foreign_key('config_id')}
  end

  it do
    should define_enum_for(:status).with_values({pending: 1, failed: 2, success: 3})
  end

  describe 'aasm states' do
    it { should have_state(:pending) }
  end

  describe 'default scope' do
    is_deleted = false
    it "should return collection whose is_deleated is false" do
      expect(is_deleted).to eq(subject.is_deleted)
    end
  end

end
