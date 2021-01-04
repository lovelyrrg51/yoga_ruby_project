# frozen_string_literal: true

class CcavenueConfigPolicy < ApplicationPolicy
  attr_reader :user
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def initialize(user, ccavenue_config)
    @user = user
    @ccavenue_config = ccavenue_config
  end

  def index?
    user.super_admin? || user.event_admin?
  end

  def create?
    index?
  end

  def new?
    index?
  end

  def edit?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index?
  end

  def payment_modes?
    user.super_admin?
  end
end
