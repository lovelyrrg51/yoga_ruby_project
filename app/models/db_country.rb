class DbCountry < ApplicationRecord
  has_many :cities, class_name: "DbCity", foreign_key: "country_id", dependent: :destroy
  has_many :states, class_name: "DbState", foreign_key: "country_id", dependent: :destroy
  has_many :addresses, inverse_of: :db_country

  validates :name, uniqueness: true, case_sensitive: false

  scope :country_name, ->(country_name) { where("name ILIKE ?", "%#{country_name}%") }

  def states_with_other
    states + DbState.other_state
  end
end
