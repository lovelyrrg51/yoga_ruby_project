class PgSyPaypalStandardConfig < ApplicationRecord
  belongs_to :payment_gateway
  belongs_to :db_country, class_name: 'DbCountry', foreign_key: 'country_id'

  delegate :currency_code, to: :db_country, allow_nil: true
end
