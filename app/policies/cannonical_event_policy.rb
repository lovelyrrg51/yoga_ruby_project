# frozen_string_literal: true

class CannonicalEventPolicy < ApplicationPolicy
  attr_reader :user, :cannonical_event
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, cannonical_event)
    @user = user
    @cannonical_event = cannonical_event
  end

  def create?
    user.super_admin? || user.digital_store_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

end
