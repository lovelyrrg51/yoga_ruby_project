class Relation < ApplicationRecord
  acts_as_paranoid

  belongs_to :sadhak_profile
  belongs_to :user
end
