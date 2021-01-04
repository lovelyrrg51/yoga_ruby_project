require 'rails_helper'

RSpec.describe ForumAttendance, type: :model do
  it { is_expected.to act_as_paranoid }
  describe "associations" do
    it { should belong_to(:sadhak_profile)}
    it { should belong_to(:sy_club_member)}
    it { should belong_to(:forum_attendance_detail)}
    it { should belong_to(:who_last_updated).class_name('User').with_foreign_key('last_updated_by')}
    it { should have_one(:digital_asset).through(:forum_attendance_detail)}
    it { should have_one(:sy_club).through(:forum_attendance_detail)}
    it { should have_one(:who_last_updated_sadhak_profile).through(:who_last_updated).source(:sadhak_profile)}
  end

  describe "validations" do
    it { should validate_presence_of(:sadhak_profile_id) }
    it { should validate_presence_of(:forum_attendance_detail_id) }
    it do
      ForumAttendance.skip_callback :save, :after, :update_forum_attendance_detail
      should validate_uniqueness_of(:sadhak_profile_id).scoped_to(:forum_attendance_detail_id).with_message("has been already added to attendance list.")
    end
  end

  describe 'delegate methods' do
    it { should delegate_method(:asset_name).to(:digital_asset).allow_nil }
    it { should delegate_method(:name).to(:sy_club).allow_nil.with_prefix('forum') }
    it { should delegate_method(:syid).to(:who_last_updated_sadhak_profile).with_prefix('who_last_updated').allow_nil }
    it { should delegate_method(:full_name).to(:who_last_updated_sadhak_profile).with_prefix('who_last_updated').allow_nil }
  end
end
