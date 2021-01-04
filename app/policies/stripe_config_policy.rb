# frozen_string_literal: true

class StripeConfigPolicy < ApplicationPolicy
  attr_reader :user, :stripe_config
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, stripe_config)
    @user = user
    @stripe_config = stripe_config
  end

  def index?
    user.super_admin? || user.event_admin?
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
    user.super_admin? || user.digital_store_admin?
  end
end
