class PgSyddConfig < ApplicationRecord

  validates :alias_name, :payment_gateway, presence: :true
  validates_uniqueness_of :alias_name

  belongs_to :payment_gateway, dependent: :destroy
  belongs_to :pg_sydd_merchant
end
