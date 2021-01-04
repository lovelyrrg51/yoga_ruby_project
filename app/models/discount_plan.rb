class DiscountPlan < ApplicationRecord

  default_scope { where(is_delete: false) }
  validates :name, :discount_amount, presence: :true
  validates_uniqueness_of :name, conditions: ->{ where(is_delete: false) }
  validates_numericality_of :discount_amount, greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100,
    if: Proc.new { |item| item.discount_type == "percentage" }

  has_many :event_discount_plan_associations, dependent: :destroy
  has_many :events, through: :event_discount_plan_associations, validate: false

  enum discount_type: {
    percentage: 1,
    fixed: 2
  }

end
