# frozen_string_literal: true

class PaymentGatewayModeAssociationPolicy < ApplicationPolicy
  attr_reader :user

  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = {})
      filtering_params.select! { |_, v| v.present? }
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end

  def initialize(user, payment_gateway_mode_association)
    @user = user
  end

  def create?
    user&.super_admin?
  end

  def show?
    create?
  end

  def new?
    create?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  def edit?
    create?
  end
end
