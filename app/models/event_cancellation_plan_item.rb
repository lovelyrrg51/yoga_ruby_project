class EventCancellationPlanItem < ApplicationRecord
  include AASM

  default_scope { where(is_deleted: false) }

  validates :days_before, :amount, :event_cancellation_plan_id, presence: true
  validates_uniqueness_of :days_before, scope: :event_cancellation_plan_id
  validates_numericality_of :amount, greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100,
    if: Proc.new { |item| item.amount_type == "percentage" }

  scope :event_cancellation_plan_id, ->(event_cancellation_plan_id) { where(event_cancellation_plan_id: event_cancellation_plan_id)  }
  scope :days_before, ->(days_before) { where(days_before: days_before) }

  belongs_to :event_cancellation_plan

  enum amount_type: {
    fixed: 0,
    percentage: 1
  }

  aasm column: :amount_type, enum: true, whiny_transitions: false do
    state :fixed, initial: true
    state :percentage
  end

  def self.preloaded_data
    EventCancellationPlanItem.includes(:event_cancellation_plan).order(:id)
  end
end
