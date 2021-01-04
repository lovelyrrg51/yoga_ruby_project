# frozen_string_literal: true

class PaymentModePolicy < ApplicationPolicy
  attr_reader :user, :payment_mode

  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = {})
      filtering_params.select! { |k, v| v.present? }
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.all
      end
    end
  end

  def initialize(user, payment_mode)
    @user = user
    @payment_mode = payment_mode
  end

  def create?
    user&.super_admin?
  end

  def index?
    create?
  end

  def show?
    create?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

end
