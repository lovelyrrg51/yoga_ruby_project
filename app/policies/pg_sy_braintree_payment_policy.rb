# frozen_string_literal: true

class PgSyBraintreePaymentPolicy < ApplicationPolicy
  attr_reader :user, :pg_sy_braintree_payment
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, pg_sy_braintree_payment)
    @user = user
    @pg_sy_braintree_payment = pg_sy_braintree_payment
  end

  def create?
    user.super_admin? || user.event_admin?
  end

  def update?
    create?
  end

  def destroy?
    user.super_admin? || user.digital_store_admin?
  end
end
