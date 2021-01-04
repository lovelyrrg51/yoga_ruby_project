# frozen_string_literal: true

class PaymentReconcilationPolicy < ApplicationPolicy
  attr_reader :user, :payment_reconcilation
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

  def initialize(user, payment_reconcilation)
    @user = user
    @payment_reconcilation = payment_reconcilation
  end

  def create?
    user&.super_admin? || user&.india_admin?
  end

  def index?
    create?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  def reconcilation?
    create?
  end

  def generate_reconcilation_file?
    create?
  end
end
