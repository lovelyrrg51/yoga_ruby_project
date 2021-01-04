require 'rails_helper'

RSpec.describe SyClubEventTypeAssociation, type: :model do

  describe "associations" do
    it { should belong_to(:sy_club) }
    it { should belong_to(:event_type) }
  end

  it do
    should define_enum_for(:status).with_values({pending: 0, approve: 1})
  end

 #AASM
  describe 'aasm states' do
    sy_club_event_type_association = FactoryBot.build(:sy_club_event_type_association)
    it { should have_state(:approve) }
    it "should transform from pending to approve" do
      expect(sy_club_event_type_association).to transition_from(:pending).to(:approve).on_event(:approve)
    end
  end
end