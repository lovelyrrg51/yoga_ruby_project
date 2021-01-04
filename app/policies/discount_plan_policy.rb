# frozen_string_literal: true

class DiscountPlanPolicy < ApplicationPolicy
  attr_reader :user, :discount_plan
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, discount_plan)
    @user = user
    @discount_plan = discount_plan
  end

  def index?
    user&.super_admin? || user&.digital_store_admin? || user&.event_admin? || user&.india_admin?
  end

  def new?
    index?
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
    index?
  end
end
