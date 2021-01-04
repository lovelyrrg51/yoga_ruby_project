# frozen_string_literal: true
class PgSyPaypalConfig < ApplicationRecord
  validates :username, :password, :signature, :alias_name, :payment_gateway, presence: true
  validates :username, :password, :signature, :alias_name, :payment_gateway, uniqueness: true

  belongs_to :payment_gateway, dependent: :destroy
  belongs_to :db_country, class_name: 'DbCountry', foreign_key: 'country_id'

  delegate :name, to: :db_country, prefix: 'country', allow_nil: true
  delegate :currency_code, to: :db_country, prefix: 'country', allow_nil: true
  delegate :ISO3, to: :db_country, prefix: 'country', allow_nil: true
end
