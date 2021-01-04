require 'rails_helper'

RSpec.describe SyEventCompany, type: :model do

  describe "associations" do

    it { should have_many(:events)}
    it { should have_many(:event_registrations)}
    it { should have_one(:address).dependent(:destroy).inverse_of(:addressable)}
  end

  describe "validations" do
    it { should validate_presence_of(:name)}
    it { should validate_presence_of(:gstin_number)}
  end

  #nested attributes
  it{ should accept_nested_attributes_for(:address).allow_destroy(true) }

  describe "delegate" do
    it { should delegate_method(:city_name).to(:address).allow_nil }
    it { should delegate_method(:state_name).to(:address).allow_nil }
    it { should delegate_method(:country_name).to(:address).allow_nil }
    it { should delegate_method(:street_address).to(:address).allow_nil }
    it { should delegate_method(:postal_code).to(:address).allow_nil }
  end

  it do
    should define_enum_for(:company_type).
      with_values({online_shivir: 0, forum: 1, main_shivir: 2, other: 3})
  end

  describe 'default scope' do
    is_deleted = false
    it "should return collection whose is_deleated is false" do
      expect(is_deleted).to eq(subject.is_deleted)
    end
  end

end
