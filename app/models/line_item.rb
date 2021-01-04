# frozen_string_literal: true

class LineItem < ApplicationRecord
  validates :order_id, presence: true
  validates :digital_asset_id, presence: true
  validate :can_add_to_order?

  belongs_to :order
  belongs_to :digital_asset

  before_save :update_total_price

  private

  def update_total_price
    # jay: can we do the follwing line with belongs_to ?
    # self.total_price = self.digital_asset.price
    self.total_price = digital_asset.price.presence || 0
  end

  def can_add_to_order?
    return if self.order.may_checkout?

    errors.add(:base, 'Can only update orders that have not had payment submitted')
  end
end
