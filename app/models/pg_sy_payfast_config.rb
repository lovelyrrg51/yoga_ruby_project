class PgSyPayfastConfig < ApplicationRecord
	include AASM

  default_scope { where(is_deleted: false) }

  validates :user_name, :alias_name, :merchant_id, :merchant_key,
    :payment_gateway, :country_id, :tax_amount, presence: :true
  validates_uniqueness_of :alias_name, conditions: lambda { where(is_deleted: false) }
  validates_numericality_of :tax_amount, greater_than_or_equal_to: 0, less_than_or_equal_to: 100

  enum pdt: { disabled: 1, enabled: 2 }

  aasm column: :pdt, enum: true do
    state :disabled, initial: true
    state :enabled
  end

  belongs_to :payment_gateway, dependent: :destroy
end
