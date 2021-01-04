require 'rails_helper'

RSpec.describe TaxType, type: :model do

  describe "associations" do

    it { should have_many(:event_tax_type_associations) }
    it { should have_many(:payment_gateway_mode_association_tax_types)}
  end

  describe "validations" do

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }

  end

  describe 'default scope' do
    is_deleted = false
    it "should return collection whose is_deleated is false" do
      expect(is_deleted).to eq(subject.is_deleted)
    end
  end

end
