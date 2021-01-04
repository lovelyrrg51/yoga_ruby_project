class DbState < ApplicationRecord
  belongs_to :country, class_name: "DbCountry", foreign_key: :country_id
  has_many :cities, class_name: "DbCity", foreign_key: "state_id", dependent: :destroy
  validates :name, uniqueness: {scope: :country_id, message: "already exist in this state", case_sensitive: false}
  has_many :addresses, inverse_of: :db_state

  scope :country_id, -> (country_id) { where(country_id: country_id) }
  scope :db_country_id, -> (country_id) { where(country_id: country_id) }
  scope :state_name, -> (state_name) { where("name ILIKE ?","%#{state_name}%") }
  scope :other_state, -> { where(name: "Others") }

  def cities_with_other
    cities + DbCity.other_city
  end
end
