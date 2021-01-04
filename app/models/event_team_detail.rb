class EventTeamDetail < ApplicationRecord
  belongs_to :sadhak_profile
  belongs_to :event#, dependant: :destroy
  validates :event, :syid, :first_name, :role, :team_type, presence: true

  enum role: {
    team_member: 0,
    team_lead: 1
  }

  enum team_type: {
    organising_team: 0,
    registration_team: 1,
    bhandara_team: 2,
    infrastructure_team: 3,
    divine_shop_team: 4,
    security_team: 5,
    parking_team: 6,
    hall_seva_team: 7,
    stage_seva_team: 8,
    publicity_awareness_team: 9,
    sound_and_lighting_team: 10,
    announcement_team: 11
  }
end
