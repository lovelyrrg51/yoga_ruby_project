require 'rails_helper'

RSpec.describe SyClubMemberActionDetail, type: :model do

  describe "associations" do
    it { should belong_to(:sadhak_profile) }
    it { should belong_to(:requester_user).class_name('User').with_foreign_key(:requester_id).optional }
    it { should belong_to(:responder_user).class_name('User').with_foreign_key(:responder_id).optional }
    it { should belong_to(:from_sy_club_member).conditions(is_deleted: [true, false]).class_name('SyClubMember').with_foreign_key('from_sy_club_member_id') }
    it { should belong_to(:to_sy_club_member).conditions(is_deleted: [true, false]).class_name('SyClubMember').with_foreign_key('to_sy_club_member_id') }
    it { should belong_to(:from_event_registration).class_name('EventRegistration').with_foreign_key('from_event_registration_id') }
    it { should have_one(:from_club).conditions(is_deleted: [true, false]).through(:from_sy_club_member).source(:sy_club) }
    it { should have_one(:to_club).conditions(is_deleted: [true, false]).through(:to_sy_club_member).source(:sy_club) }
  end

  describe "validations" do
    it { should validate_presence_of(:from_sy_club_member_id) }
    it { should validate_presence_of(:to_sy_club_member_id) }
    it { should validate_presence_of(:from_event_registration_id) }
    it { should validate_presence_of(:to_event_registration_id) }
    it { should validate_presence_of(:sadhak_profile_id) }
  end

  describe 'default scope' do
    is_deleted = false
    it "should return collection whose is_deleated is false" do
      expect(is_deleted).to eq(subject.is_deleted)
    end
  end

  it do
    should define_enum_for(:action_type).with([ :transfer, :renew ])
    should define_enum_for(:status).with([ :requested, :approved ])
  end

  #AASM
  describe 'aasm states' do
    sy_club_member_action_detail = FactoryBot.build_stubbed(:sy_club_member_action_detail)
    it { should have_state(:requested) }
    # it "should transform from requested to approved" do
    #   expect(sy_club_member_action_detail).to transition_from(:requested).to(:approved).on_event(:approve)
    # end
  end
end