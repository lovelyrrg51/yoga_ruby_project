class SadhakSevaPreference < ApplicationRecord
  acts_as_paranoid

  REQUIRED_FIELD = [ :seva_preference, :availability]
  belongs_to :sadhak_profile
  validates :sadhak_profile_id, uniqueness: true, on: :create
  validates :other_seva_preference, presence: true, if: Proc.new { |a| a.seva_preference == "other" }

  enum availability: {
    before_2_hours: 1,
    during_breaks: 2,
    after_1_hour: 3
  }

  enum seva_preference: {
    hall: 1,
    catering: 2,
    car_park: 3,
    divine_shop: 4,
    shoe: 5,
    facilities: 6,
    registeration: 7,
    stage: 8,
    music: 9,
    queue_management: 10,
    other: 11
  }
end
