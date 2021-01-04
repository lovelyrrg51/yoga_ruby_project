class SyClubExceptionPrice < ApplicationRecord
  belongs_to :db_country, class_name: 'DbCountry', foreign_key: 'country_id'

  validates :country_id, presence: true
  validates :price, presence: true
  validates :currency, presence: true
  validates :currency, uniqueness: { scope: :country_id }

  auto_strip_attributes :currency
end
