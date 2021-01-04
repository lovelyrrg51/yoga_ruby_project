class EventSeatingCategoryAssociation < ApplicationRecord
  has_paper_trail class_name: 'EventSeatingCategoryAssociationVersion', only: [:event_id, :seating_category_id, :price, :seating_capacity, :cancellation_charge, :is_deleted], skip: [], on: [:update, :destroy]

  default_scope { where(is_deleted: false) }

  validates :event, :seating_category, presence: true
  validates_uniqueness_of :seating_category, conditions: lambda { where(is_deleted: false) }, scope: :event
  validates :price, presence: true, numericality: true

  belongs_to :event
  belongs_to :seating_category
  has_many :event_order_line_items
  has_many :valid_event_registrations, lambda { where(event_registrations: {status: EventRegistration.valid_registration_statuses}) }, class_name: "EventRegistration"

  delegate :category_name, to: :seating_category, allow_nil: true

  before_save :check_for_event_registrations, if: Proc.new { |esca| is_deleted_changed? and esca.is_deleted? }
  before_save :check_for_valid_obj
  before_destroy :check_for_event_registrations

  def seats_available
    seats_occupied = EventRegistration.where(status: EventRegistration.valid_registration_statuses, event_seating_category_association_id: self.id, event_id: self.event_id).size
    self.seating_capacity.to_i - seats_occupied < 0 ? 0 : self.seating_capacity.to_i - seats_occupied
  end

  private

  def check_for_event_registrations
    registrations_count = EventRegistration.where(event_seating_category_association_id: id, event_id: event_id).size
    errors.add("#{registrations_count}", " registration(s) exist against #{category_name} category. Unable to delete.") if registrations_count > 0
    throw(:abort) unless errors.empty?
  end

  def check_for_valid_obj
    ApplicationRecord.transaction do
      raise SyException, self.errors.full_message.first unless self.valid?
    end
  end
end
