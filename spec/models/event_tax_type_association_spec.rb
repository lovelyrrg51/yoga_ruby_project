require 'rails_helper'

RSpec.describe EventTaxTypeAssociation, type: :model do
  describe "associations" do
    it { should belong_to(:event).inverse_of(:event_tax_type_associations)}
    it { should belong_to(:tax_type)}
  end

  describe "validations" do

    it { should validate_presence_of(:tax_type) }
    it { should validate_presence_of(:event) }
    it { should validate_presence_of(:percent) }
    it { should validate_numericality_of(:percent).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
    # it { should validate_uniqueness_of(:tax_type).scoped_to(:event).with_message("Tax type has already been taken.") }
  end

  describe 'delegate methods' do
    it { should delegate_method(:name).to(:tax_type).with_prefix('tax_type').allow_nil }
  end

  describe 'default scope' do
    is_deleted = false
    it "should return collection whose is_deleated is false" do
      expect(is_deleted).to eq(subject.is_deleted)
    end
  end
end
