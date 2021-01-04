class PaymentRefundPolicy < ApplicationPolicy
  attr_reader :payment_refund
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end

  def initialize(user, payment_refund)
    @payment_refund = payment_refund
    super(user, payment_refund.event)
  end

  def create?
    # if user is super admin or event admin
    user.present? and (user.super_admin? or user.event_admin? or user.india_admin?)
  end

  def update?
    # if user is super admin or event admin
    user.present? and (user.super_admin? or user.event_admin? or user.india_admin? or permissions[:country_admin] or permissions[:per_event_admin])
  end

  def destroy?
    # if user is super admin or event admin
    user.present? and (user.super_admin? or user.event_admin? or user.india_admin?)
  end

  def refund?
    user.present? && (user.event_admin? || user.super_admin? || permissions[:india_admin] || permissions[:country_admin] || permissions[:per_event_admin])
  end
end
