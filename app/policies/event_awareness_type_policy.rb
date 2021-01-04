# frozen_string_literal: true

class EventAwarenessTypePolicy < ApplicationPolicy
  attr_reader :user, :event_awareness_type
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, event_awareness_type)
    @user = user
    @event_awareness_type = event_awareness_type
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
