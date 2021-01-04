require 'rails_helper'

RSpec.describe EventTeamDetail, type: :model do
  describe "associations" do
    it { should belong_to(:sadhak_profile)}
    it { should belong_to(:event)}
  end

  describe "validations" do

    it { should validate_presence_of(:event) }
    it { should validate_presence_of(:syid) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:team_type) }
  end

  it do
    should define_enum_for(:role).with_values({team_member: 0, team_lead: 1})
    should define_enum_for(:team_type).with_values({organising_team: 0, registration_team: 1, bhandara_team: 2, infrastructure_team: 3, divine_shop_team: 4, security_team: 5, parking_team: 6, hall_seva_team: 7, stage_seva_team: 8, publicity_awareness_team: 9, sound_and_lighting_team: 10, announcement_team: 11})
  end
end
