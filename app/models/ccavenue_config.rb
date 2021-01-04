class CcavenueConfig < ApplicationRecord
  belongs_to :payment_gateway, dependent: :destroy
  validates :alias_name, :payment_gateway, presence: :true
  validates :alias_name, uniqueness: true
end
