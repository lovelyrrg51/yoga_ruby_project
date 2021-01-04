require 'rails_helper'

RSpec.describe GlobalPreference, type: :model do

  describe "validations" do
    it { should validate_uniqueness_of(:key) }
  end

  it do
    should define_enum_for(:input_type).with_values({text_field: 0, text_area: 1, tagsinput: 2, check_box: 3})
    should define_enum_for(:group_name).with_values({Event: 0, SadhakProfile: 1, SyClub: 2})
  end

  describe 'default scope' do
    is_deleted = false
    it "should return collection whose is_deleated is false" do
      expect(is_deleted).to eq(subject.is_deleted)
    end
  end
end
