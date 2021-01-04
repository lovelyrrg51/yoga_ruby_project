# frozen_string_literal: true

class PaymentGatewayPolicy < ApplicationPolicy
  attr_reader :user, :payment_gateway
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      filtering_params.select! { |k,v| v.present? }
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end

  def initialize(user, payment_gateway)
    @user = user
    @payment_gateway = payment_gateway
  end

  def create?
    user.super_admin? || user.digital_store_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
