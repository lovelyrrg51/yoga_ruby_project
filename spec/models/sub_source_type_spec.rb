require 'rails_helper'

RSpec.describe SubSourceType, type: :model do

  describe "associations" do
    it { should belong_to(:source_info_type) }
  end

  describe "validations" do
    it { should validate_presence_of(:source_info_type_id) }
    it { should validate_presence_of(:sub_source_name) }
    context "when a is_deleted is false" do
      subject { SubSourceType.new(is_deleted: false) }
      it { should validate_uniqueness_of(:sub_source_name).scoped_to(:source_info_type_id).ignoring_case_sensitivity }
    end
  end

  describe 'default scope' do
    is_deleted = false
    it "should return collection whose is_deleated is false" do
      expect(is_deleted).to eq(subject.is_deleted)
    end
  end
end