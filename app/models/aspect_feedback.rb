class AspectFeedback < ApplicationRecord
  acts_as_paranoid

  validates :aspect_type, uniqueness: { scope: :aspects_of_life_id }

  # Five Point Scale
  VERY_BAD = 0
  BAD = 1
  NEUTRAL = 2
  GOOD = 3
  EXCELLENT = 4

  # ASPECT_TYPE
  FAMILY_HAPPINESS = 0
  RELATIONSHIP = 1
  PEACE_OF_MIND = 2
  CAREER = 3
  HEALTH = 4
  FINANCES = 5
  SADHANA_FREQUENCY = 6

  #enum five_point_scale: [:very_bad, :bad, :neutral, :good, :excellent]
  enum aspect_type: {family_happiness: 0, relationship: 1, peace_of_mind: 2, career: 3, health: 4, finances: 5, sadhana_frequency: 6}
  belongs_to :aspects_of_life
end
