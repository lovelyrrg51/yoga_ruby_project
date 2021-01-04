class Voucher < ActiveRecord::Base
  include AASM

  acts_as_paranoid

  belongs_to :receiptable, polymorphic: true
  has_many :attachments, as: :attachable
  has_one :attachment, ->{ order('id DESC') }, as: :attachable

  enum voucher_type: [ :receipt, :invoice, :refund ]

  aasm column: :voucher_type, enum: true do
    state :receipt, initial: true
    state :invoice
    state :refund
  end

  validates :voucher_number, :receiptable, :voucher_type, presence: true

  delegate :s3_filepath, to: :attachment, allow_nil: true

end
