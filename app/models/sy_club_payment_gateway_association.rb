class SyClubPaymentGatewayAssociation < ApplicationRecord
  include Filterable
  include CommonHelper

  belongs_to :payment_gateway

  scope :sy_club_id, ->(sy_club_id) { where(sy_club_id: sy_club_id) }

  before_create :check_existing_association

  protected
  def check_existing_association
    if self.class.count > 0
      errors.add(:sy_club_payment_gateway_association, "Forum cannot have more than one payment gatway at a time, only updation is allowed")
      false
    else
      true
    end
  end
end
