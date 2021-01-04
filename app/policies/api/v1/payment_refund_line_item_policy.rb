class Api::V1::PaymentRefundLineItemPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :payment_refund_line_item
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end

  def initialize(user, payment_refund_line_item)
    @user = user
    @payment_refund_line_item = payment_refund_line_item
  end

  def create?
    # if user is super admin or event admin
    user.present? and (user.super_admin? or user.event_admin?)
  end
  
  def update?
    # if user is super admin or event admin
    user.present? and (user.super_admin? or user.event_admin?)
  end
  
  def destroy?
    # if user is super admin or event admin
    user.present? and (user.super_admin? or user.event_admin?)
  end

  def show?
  	# if user is super admin or event admin
    user.present? and (user.super_admin? or user.event_admin?)
  end
end
