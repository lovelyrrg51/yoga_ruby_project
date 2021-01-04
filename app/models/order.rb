class Order < ApplicationRecord
  include AASM
#  @allowed_currency = ["INR", "USD"]
#  validates :billing_address, presense: true, length: { maximum: 255 }
#  validates :billing_address_city, presense: true, length: { maximum: 255 }
#  validates :billing_address_state, presense: true, length: { maximum: 255 }
#  validates :billing_address_country, presense: true, length: { maximum: 255 }
#  validates :billing_address_postal_code, presense: true, length: { maximum: 10 }
#  validates :billing_phone, presense: true, length: { maximum: 255 }
#  validates_format_of :billing_phone, :with => /REGEX HERE/i

#  validates :billing_email, presense: true, length: { maximum: 255 }
#  validates_format_of :billing_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
#  validates :billing_name, presense: true, length: { maximum: 255 }
#  validates :currency, :inclusion => { :in => @allowed_currency }
#  validates :total_amount, presence: true, :numericality => { :greater_than => 0 }
#  validates :user_id, presence: true

  @@items_payment_pending = []
  attr_accessor :purchased_line_items
  has_many :line_items
  has_many :digital_assets, through: :line_items
  belongs_to :user

  enum status: {
    cart: 0,
    payment_success: 1,
    delivered: 2,
    closed: 3
  }

  aasm column: :status, enum: true do
    state :cart, initial: true
    state :payment_success
    state :delivered
    state :closed

    event :checkout, after: Proc.new{after_checkout} do
      transitions from: :cart, to: :payment_submitted
    end

    event :successful_payment, after: Proc.new{after_successful_payment} do
      transitions from: [:cart], to: :payment_success
    end

    event :deliver_order do
      transitions from: :payment_success, to: :delivered
    end

    event :abort_order do
      transitions from: [:cart], to: :closed
    end
  end

  before_save :update_order_total

  # def after_checkout
  #jay: changing model to create new order on success.
  def after_successful_payment
    add_digital_assets_to_library
    logger.info "pending items"
    logger.info @@items_payment_pending
    self.user&.create_empty_order(@@items_payment_pending)
  end

  def update_order_total
    #jay: this was  ||= 0 which lead to repeat counting on every update
    self.total_amount = 0
    self.line_items.each do |item|
      self.total_amount = self.total_amount + item.total_price
    end
    self.currency = "INR"
  end

  def  update_order(params)
    if params.has_key?("digital_asset_ids") && may_checkout?
      logger.info "asset id is "
      logger.info params[:digital_asset_ids]
      #params[:digital_asset_ids].each{|asset_id| self.line_items.create(digital_asset_id: asset_id, order_id: self.id)}
      params[:digital_asset_ids].each{|asset_id| self.line_items.find_or_create_by(digital_asset_id: asset_id, order_id: self.id)}
    end
    if may_checkout? && params.has_key?(:checkout) && params[:checkout]
      checkout
    end
    update_attributes(params.except(:digital_asset_ids, :checkout))
    #this method contains all the logic that defines the steps of updating an order - this runs after all validations have passed for each step
  end

  def add_digital_assets_to_library
    logger.info "purchased items"
    logger.info self.purchased_line_items
    self.line_items.each do |item|
      # check if payment was done for current line_item
      if self.purchased_line_items.include?(item.digital_asset_id.to_s)
        PurchasedDigitalAsset.create(user_id: self.user_id, digital_asset_id: item.digital_asset_id)
      else
        @@items_payment_pending.push(item.id)
      end
    end
  end

  end


#  current checkout process:
#   1.) call update_order with params to add digital assets to cart (checkout) -> this generates the total amount on the order
#   2.) call update_order with params to fill in billing attributes (payment submitted)
#   3.) call upda
