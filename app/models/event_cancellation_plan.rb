class EventCancellationPlan < ApplicationRecord
  default_scope { where(is_deleted: false) }

  validates :name, presence: true
  validates_uniqueness_of :name, conditions: ->{ where(is_deleted: false) }

  has_many :event_cancellation_plan_items, dependent: :destroy
  has_many :events
  has_many :payment_refunds

  before_update :update_dependent, if: :is_deleted_changed?

  scope :event_cancellation_plan_name, ->(event_cancellation_plan_name) { where("name ILIKE ?", "%#{event_cancellation_plan_name}%" ) }

  def self.preloaded_data
    EventCancellationPlan.includes(:events, :event_cancellation_plan_items).order(:id)
  end

  private
  def update_dependent
    event_cancellation_plan_items = self.event_cancellation_plan_items.unscoped.where(event_cancellation_plan_id: self.id)
    count = event_cancellation_plan_items.count
    errors.add(:there, "is some error while deleting event cancellation plan line items.") if count != event_cancellation_plan_items.update_all(is_deleted: self.is_deleted)
  end
end
