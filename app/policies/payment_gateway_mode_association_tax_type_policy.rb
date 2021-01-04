# frozen_string_literal: true

class PaymentGatewayModeAssociationTaxTypePolicy < ApplicationPolicy
  attr_reader :user, :payment_gateway_mode_association_tax_type

  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = {})
      filtering_params.select! { |k, v| v.present? }
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end

  def initialize(user, payment_gateway_mode_association_tax_type)
    @user = user
    @payment_gateway_mode_association_tax_type = payment_gateway_mode_association_tax_type
  end

  def create?
    user&.super_admin?
  end

  def show?
    create?
  end

  def update?
    show?
  end

  def destroy?
    update?
  end
end
