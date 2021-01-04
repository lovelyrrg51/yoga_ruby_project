class DbCity < ApplicationRecord
  belongs_to :country, class_name: "DbCountry", foreign_key: :country_id
  belongs_to :state, class_name: "DbState", foreign_key: :state_id
  has_many :addresses, foreign_key: :city_id

  validates :name, presence: true, uniqueness: {
    scope: [:state_id, :country_id],
    message: "This state is already exists.",
    case_sensitive: false
  }

  scope :state_id, -> (state_id) { where(state_id: state_id) }
  scope :other_city, -> { where(name: "Others") }
  scope :city_name, ->(city_name) { where("name ILIKE ?", "%#{city_name}%") }
  scope :db_state_id, -> (state_id) { where(state_id: state_id) }
  scope :db_country_id, -> (country_id) { where(country_id: country_id) }
end
