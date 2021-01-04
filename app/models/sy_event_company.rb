class SyEventCompany < ApplicationRecord
  default_scope { where(is_deleted: false) }

  validates :name, :gstin_number, presence: :true

  has_many :events
  has_one :address, as: :addressable, dependent: :destroy, inverse_of: :addressable
  has_many :event_registrations

  accepts_nested_attributes_for :address, allow_destroy: true

  scope :sy_event_company_name, ->(sy_event_company_name) { where("name ILIKE ?", "%#{sy_event_company_name}%") }

  delegate :city_name, to: :address, allow_nil:  true
  delegate :state_name, to: :address, allow_nil: true
  delegate :country_name, to: :address, allow_nil: true
  delegate :street_address, to: :address, allow_nil: true
  delegate :postal_code, to: :address, allow_nil: true

  before_save :initialize_prefix

  enum company_type: {online_shivir: 0, forum: 1, main_shivir: 2, other: 3}

  def is_shiv_yog_herbs_llp?
    # SyEventCompany id: 9, name: "Shiv Yog Herbs LLP"
    id.eql? 9
  end

  def initialize_prefix
    self[:invoice_prefix] = invoice_prefix
    self[:refund_prefix] = refund_prefix
    self[:receipt_prefix] = receipt_prefix
  end

  def invoice_prefix
    return super unless self[:invoice_prefix].blank?
    prefix = if online_shivir?
      'LS/'
    elsif forum?
      'FM/'
    elsif main_shivir?
      "MS/"
    end
    return prefix
  end

  def refund_prefix
    return super unless self[:refund_prefix].blank?
    if online_shivir?
      'RFV/LS/DEL/'
    elsif forum?
      'RFV/FM/DEL/'
    elsif main_shivir?
      "RFV/MS/#{state_code}/"
    end
  end

  def receipt_prefix
    return super unless self[:receipt_prefix].blank?
    prefix = if online_shivir?
      'RV/LS/DEL/'
    elsif forum?
      'RV/FM/DEL/'
    elsif main_shivir?
      "RV/MS/#{state_code}/"
    end
  end

  private
  def state_code
    STATE_WITH_INVOICE_CODE[address.try(:state_name).to_s.try(:titleize)].try(:[], :code) || 'DL'
  end
end
