# frozen_string_literal: true

class EventDiscountPlanAssociationPolicy < ApplicationPolicy
 	attr_reader :user, :event_discount_plan_association
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def initialize(user, event_discount_plan_association)
    @user = user
    @event_discount_plan_association = event_discount_plan_association
  end

  def create?
    user.super_admin? || user.digital_store_admin? || user.event_admin? || user.india_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
