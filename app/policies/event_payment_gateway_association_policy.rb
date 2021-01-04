# frozen_string_literal: true

class EventPaymentGatewayAssociationPolicy < ApplicationPolicy
  attr_reader :user, :event_payment_gateway_association
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end

  def initialize(user, event_payment_gateway_association)
    @user = user
    @event_payment_gateway_association = event_payment_gateway_association
  end

  def create?
    user&.super_admin? || user&.digital_store_admin? || user&.event_admin? ||
      user&.india_admin?
  end

  def update?
   create?
  end

  def destroy?
   create?
  end
end
