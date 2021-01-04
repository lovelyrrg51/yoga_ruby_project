require 'rails_helper'

RSpec.describe ForumAttendanceDetail, type: :model do
  subject { build :forum_attendance_detail, digital_asset: build(:digital_asset) }

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:digital_asset) }
    it { should belong_to(:sy_club) }
    it { should belong_to(:creator).class_name('User').with_foreign_key('creator_id') }
    it { should have_many(:forum_attendances) }
    it { should have_one(:who_last_updated_sadhak_profile).through(:who_last_updated).source(:sadhak_profile) }
  end

  describe "validations" do
    it { should validate_presence_of(:conducted_on) }
    it { should validate_numericality_of(:edit_count).only_integer.is_less_than_or_equal_to(FORUM_ATTENDANCE_ALLOWED_EDIT_COUNT).is_greater_than_or_equal_to(0) }
  end

  describe 'delegate methods' do
    it { should delegate_method(:asset_name).to(:digital_asset).allow_nil }
    it { should delegate_method(:published_on).to(:digital_asset).allow_nil }
    it { should delegate_method(:name).to(:sy_club).with_prefix('forum').allow_nil }
    it { should delegate_method(:syid).to(:who_last_updated_sadhak_profile).with_prefix('who_last_updated').allow_nil }
    it { should delegate_method(:full_name).to(:who_last_updated_sadhak_profile).with_prefix('who_last_updated').allow_nil }
  end
end
