class DsProductInventoryRequest < ApplicationRecord
  include AASM

  belongs_to :ds_shop
  has_many :ds_inventory_requests
  after_update :check_status_of_request
  validates :ds_shop_id, presence: true

  enum status: {
    requested: 0,
    delivered: 1,
    received: 2,
    closed: 3
  }

  aasm column: :status, enum: true do
    state :requested, initial: true
    state :delivered
    state :received
    state :closed

    event :receive, after: Proc.new { after_delivered } do
      transitions from: :requested, to: :received
    end

    event :deliver, after: Proc.new { after_delivered } do
      transitions from: [:requested, :received], to: :delivered
    end

    event :close do
      transitions from: :received, to: :closed
    end
  end

  def check_status_of_request
    logger.info self.status
    if self.status == 'closed'
      ds_inventory_request = DsInventoryRequest.where("ds_product_inventory_request_id = ? ", self.id)
      logger.info ds_inventory_request
      ds_product_inventory_params = {ds_shop_id: "#{self.ds_shop_id}", ds_product_id: self.ds_inventory_requests.last.ds_product_id}
      ds_product_inventory = DsProductInventory.create(ds_product_inventory_params)
      logger.info ds_product_inventory_params
      logger.info self.ds_inventory_requests.last.ds_product_id
    else
      logger.info "Status in not closed"
      false
    end
  end
end
