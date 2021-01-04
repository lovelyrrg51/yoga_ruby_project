class EventTaxTypeAssociation < ApplicationRecord
  belongs_to :event, inverse_of: :event_tax_type_associations
  belongs_to :tax_type

  validates :tax_type, :event, :percent, presence: true
  validates :tax_type, uniqueness: { scope: :event,  conditions: lambda { where( is_deleted: false) },  message: "Tax type has already been taken." }
  validates_numericality_of :percent, greater_than_or_equal_to: 0, less_than_or_equal_to: 100

  delegate :name, to: :tax_type, prefix: 'tax_type', allow_nil: true
  default_scope { where(is_deleted: false) }

  before_save :check_for_valid_obj

  private

  def check_for_valid_obj
    raise SyException, self.errors.full_messages.first unless self.valid?
  end
end
