require 'rails_helper'

RSpec.describe SyClubSadhakProfileAssociation, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:sy_club) }
    it { should belong_to(:sadhak_profile) }
    it { should belong_to(:sy_club_user_role) }
    it { should belong_to(:sy_club_validity_window) }
  end

  describe "validations" do
    sadhak_profile = SadhakProfile.count > 0 ? SadhakProfile.last : SadhakProfile.create(first_name: "test", last_name: "test", date_of_birth: "1980-03-05", gender: "male", user_id: 98)
    subject {SyClubSadhakProfileAssociation.new(sadhak_profile_id: sadhak_profile.id, sy_club_user_role_id: 1)}
    it { should validate_presence_of(:sadhak_profile) }
    it { should validate_presence_of(:sy_club) }
    it { should validate_presence_of(:sy_club_user_role) }
    # it { should validate_uniqueness_of(:sadhak_profile_id).scoped_to(:sy_club_id).with_message('Board member already assigned a role in this forum.') }
    # it { should validate_uniqueness_of(:sy_club_user_role_id).scoped_to(:sy_club_id).with_message('Role already exist in this forum.') }
  end

  it { should delegate_method(:role_name).to(:sy_club_user_role).allow_nil }

  it do
    should define_enum_for(:status).with_values({pending: 0, approve: 1, expired: 2})
  end

  #AASM
  describe 'aasm states' do
    sy_club_sadhak_profile_association = FactoryBot.build(:sy_club_sadhak_profile_association)
    it { should have_state(:pending) }
    it "should transform from pending to approve" do
      expect(sy_club_sadhak_profile_association).to transition_from(:pending).to(:approve).on_event(:approve)
    end
  end
end