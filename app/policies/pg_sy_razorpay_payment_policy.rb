# frozen_string_literal: true

class PgSyRazorpayPaymentPolicy < ApplicationPolicy
  attr_reader :user, :pg_sy_razorpay_payment
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, razorpay_config)
    @user = user
    @pg_sy_razorpay_payment = razorpay_config
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
