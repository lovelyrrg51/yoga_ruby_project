require 'rails_helper'

RSpec.describe SyClubMemberTransfer, type: :model do

  # table does not exist

  # describe "associations" do
  #   it { should belong_to(:sadhak_profile) }
  #   it { should belong_to(:requester_user).class_name('User').with_foreign_key(:requester_id) }
  #   it { should belong_to(:responder_user).class_name('User').with_foreign_key(:responder_id) }
  #   it { should belong_to(:transfer_out_club).class_name('SyClub').with_foreign_key(:from_club_id) }
  #   it { should belong_to(:transfer_in_club).class_name('SyClub').with_foreign_key(:to_club_id) }
  #   it { should belong_to(:sy_club_member) }
  # end

  # describe "validations" do
  #   it { should validate_presence_of(:sy_club_member_id) }
  #   it { should validate_presence_of(:sadhak_profile_id) }
  #   it { should validate_presence_of(:from_club_id) }
  #   it { should validate_presence_of(:to_club_id) }
  #   it { should validate_presence_of(:requester_id) }
  # end

  # describe 'default scope' do
  #   is_deleted = false
  #   it "should return collection whose is_deleated is false" do
  #     expect(is_deleted).to eq(subject.is_deleted)
  #   end
  # end

  # it do
  #   should define_enum_for(:transfer_reason).with_values({forum_near: 0, forum_timing: 1, relocation: 2, others: 4})
  #   should define_enum_for(:status).with_values({forum_near: 0, forum_timing: 1, relocation: 2, others: 4})
  # end

  #AASM
  # describe 'aasm states' do
  #   sy_club_member_transfer = FactoryBot.build(:sy_club_member_transfer)
  #   it { should have_state(:requested) }
  #   it "should transform from requested to approved" do
  #     expect(sy_club_member_transfer).to transition_from(:requested).to(:approved).on_event(:approve)
  #   end
  #   it "should transform from requested to refer backed" do
  #     expect(sy_club_member_transfer).to transition_from(:requested).to(:refer_backed).on_event(:refer_back)
  #   end
  #   it "should transform from requested to cancelled" do
  #     expect(sy_club_member_transfer).to transition_from(:requested).to(:cancelled).on_event(:cancel)
  #   end
  # end
end