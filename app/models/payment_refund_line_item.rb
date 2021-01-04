class PaymentRefundLineItem < ApplicationRecord
  include AASM
  acts_as_paranoid

  def paranoia_restore_attributes
    {
      deleted_at: nil,
      is_deleted: false
    }
  end

  def paranoia_destroy_attributes
    {
      deleted_at: current_time_from_proper_timezone,
      is_deleted: true
    }
  end

  scope :sadhak_profile_id, lambda { |sadhak_profile_id| where(sadhak_profile_id: sadhak_profile_id) }
  scope :event_registration_id, lambda { |event_registration_id| where(event_registration_id: event_registration_id) }
  scope :event_id, lambda { |event_id| where(event_id: event_id) }
  scope :event_seating_category_association_id, lambda { |event_seating_category_association_id| where(event_seating_category_association_id: event_seating_category_association_id) }
  scope :payment_refund_id, lambda { |payment_refund_id| where(payment_refund_id: payment_refund_id) }

  belongs_to :sadhak_profile
  belongs_to :event_registration
  belongs_to :event
  belongs_to :event_seating_category_association
  belongs_to :payment_refund
  belongs_to :event_order_line_item
  has_one :registered_sadhak_profile, through: :event_registration, source: :sadhak_profile
  has_one :line_item_sadhak_profile, through: :event_order_line_item, source: :sadhak_profile
  has_one :seating_category, through: :event_seating_category_association

  delegate :price, to: :event_seating_category_association, prefix: "category", allow_nil: true
  delegate :category_name, to: :event_seating_category_association, allow_nil: true
  delegate :syid, to: :sadhak_profile, allow_nil: true
  delegate :full_name, to: :sadhak_profile, allow_nil: true

  validates :event_registration_id, :payment_refund_id, presence: true

  before_create :is_request_already_placed?, :assign_new_item_status

  enum status: { requested: 0, done: 1, request_cancelled: 2 }

  enum old_item_status: {
    cancelled: 0,
    transferred: 1,
    updated: 2,
    success: 3,
    cancelled_refunded: 4,
    cancelled_refund_pending: 5,
    upgraded: 6,
    downgraded: 7,
    name_changed: 8,
    shivir_changed: 9,
    downgrade_requested: 10,
    shivir_change_requested: 11,
    name_change_requested: 12,
    upgrade_requested: 13,
    expired: 14,
    renewed: 15
  }

  aasm column: :status, enum: true, whiny_transitions: false do
    state :requested, initial: true
    state :done
    state :request_cancelled

    event :do, before: [], guards: [], after_commit: [] do
      transitions from: :requested, to: :done
    end
  end

  def self.preloaded_data
    PaymentRefundLineItem.includes(:sadhak_profile, :event_registration,
      :event_order_line_item, :registered_sadhak_profile,
      :line_item_sadhak_profile, :event, :event_seating_category_association,
      :payment_refund)
  end

  # For Payment refund
  def assign_new_item_status
    details =  (self.payment_refund.request_object || {}).deep_symbolize_keys[:details]
    reg_detail = (details || []).find{|d| d[:event_registration_id].to_i == self.event_registration_id}
    return if reg_detail.nil?
    is_transfer = reg_detail[:is_transferred]
    touched_columns = reg_detail[:touched_columns]
    category_amount_diff = reg_detail[:category_amount_diff].to_f
    if touched_columns.size > 0
      if is_transfer
        new_status = EventRegistration.statuses["shivir_change_requested"]

      elsif category_amount_diff > 0
        new_status = EventRegistration.statuses["downgrade_requested"]

      elsif category_amount_diff < 0
        new_status = EventRegistration.statuses["upgrade_requested"]

      elsif touched_columns.include?("sadhak_profile_id")
        new_status = EventRegistration.statuses["name_change_requested"]
      end
    else
      new_status = EventRegistration.statuses["cancelled_refund_pending"]
    end
    self.new_item_status = new_status
  end

  private
  # Check wether request is already placed or not
  def is_request_already_placed?
    placed_request = self.class.find_by(event_registration_id: self.event_registration_id, status: self.class.statuses["requested"])
    errors.add(:SYID, ": #{self.try(:event_registration).try(:sadhak_profile_id)} is already created a #{placed_request.try(:payment_refund).try(:action)} request.") if placed_request.present?
    errors.empty?
  end
end
