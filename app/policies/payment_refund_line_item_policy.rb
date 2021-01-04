# frozen_string_literal: true

class PaymentRefundLineItemPolicy < ApplicationPolicy
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
    user.super_admin? || user.event_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  def show?
    create?
  end
end
