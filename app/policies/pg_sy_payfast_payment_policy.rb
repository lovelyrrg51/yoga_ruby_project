# frozen_string_literal: true

class PgSyPayfastPaymentPolicy < ApplicationPolicy
  attr_reader :user, :pg_sy_payfast_payment
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      filtering_params.nil? ? scope.all : scope.filter(filtering_params)
    end
  end

  def initialize(user, pg_sy_payfast_payment)
    @user = user
    @pg_sy_payfast_payment = pg_sy_payfast_payment
  end

  def create?
    user&.super_admin? || user&.india_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
