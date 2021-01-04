# frozen_string_literal: true

class PaymentGatewayTypePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin? || user.digital_store_admin?
        scope.all
      else
        []
      end
    end
  end

  def initialize(user, payment_gateway_type)
    @user = user
    @payment_gateway_type = payment_gateway_type
  end

  def index?
    user.super_admin? || user.digital_store_admin?
  end

  def new?
    index?
  end

  def create?
    index?
  end

  def edit?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index?
  end
end
