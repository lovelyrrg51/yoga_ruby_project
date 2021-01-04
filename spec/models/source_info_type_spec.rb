require 'rails_helper'

RSpec.describe SourceInfoType, type: :model do

  describe "associations" do
    it { should have_many(:sub_source_types).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:source_name) }
    context "when a is_deleted is false" do
      subject { SourceInfoType.new(is_deleted: false) }
      it { should validate_uniqueness_of(:source_name).ignoring_case_sensitivity }
    end
  end

  describe 'default scope' do
    is_deleted = false
    it "should return collection whose is_deleated is false" do
      expect(is_deleted).to eq(subject.is_deleted)
    end
  end
end