require 'rails_helper'

RSpec.describe SyClubMember, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:sy_club) }
    it { should belong_to(:sadhak_profile) }
    it { should belong_to(:sy_club_validity_window).optional }
    it { should belong_to(:event_registration).optional }
    it { should have_one(:event_order_line_item).through(:event_registration) }
    it { should belong_to(:transferred_to_club).class_name('SyClub').with_foreign_key(:transferred_to_club_id).optional }
    it { should have_many(:forum_attendances).dependent(:destroy) }
  end

  describe 'delegate methods' do
    it { should delegate_method(:name).to(:transferred_to_club).with_prefix('transferred_club').allow_nil }
    it { should delegate_method(:name).to(:sy_club).allow_nil.with_prefix('forum') }
    it { should delegate_method(:full_name).to(:sadhak_profile).with_prefix('sadhak').allow_nil }
    it { should delegate_method(:syid).to(:sadhak_profile).with_prefix('sadhak').allow_nil }
    it { should delegate_method(:clp_event).to(:sy_club).allow_nil }
    it { should delegate_method(:board_member_position).to(:sadhak_profile).allow_nil }
    it { should delegate_method(:board_member_forum_name).to(:sadhak_profile).allow_nil }
  end

  # describe 'validations' do
  #   subject {SyClubMember.new(is_deleted: false, status: SyClubMember.statuses["approve"], sadhak_profile_id: SadhakProfile.first.id)}
  #   it { should validate_uniqueness_of(:sadhak_profile_id).scoped_to(:sy_club_id).with_message('member already registered for this forum.') }
  # end

  it do
    should define_enum_for(:virtual_role).with_values({organiser: 0})
    should define_enum_for(:status).with_values({pending: 0, approve: 1, expired: 2, renewed: 3, transferred: 4, cancelled: 5})
  end

  #AASM
  describe 'aasm states' do
    sy_club_member = FactoryBot.build(:sy_club_member)
    it { should have_state(:pending) }
    it "should transform from pending to approve" do
      expect(sy_club_member).to transition_from(:pending).to(:approve).on_event(:approve)
    end
    it "should transform from approve to expired" do
      expect(sy_club_member).to transition_from(:approve).to(:expired).on_event(:expired)
    end
    it "should transform from expired to renewed" do
      expect(sy_club_member).to transition_from(:expired).to(:renewed).on_event(:renewed)
    end
    it "should transform from approve to transferred" do
      expect(sy_club_member).to transition_from(:approve).to(:transferred).on_event(:transfer)
    end
    it "should transform from approve to cancelled" do
      expect(sy_club_member).to transition_from(:approve).to(:cancelled).on_event(:cancel)
    end
  end
end
