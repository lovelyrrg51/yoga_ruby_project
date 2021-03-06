# frozen_string_literal: true

class EventCancellationPlanItemPolicy < ApplicationPolicy
  attr_reader :user, :event_cancellation_plan_item
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      filtering_params.select! { |k, v| v.present? }
      if filtering_params.blank?
        scope.none
      else
        scope.filter(filtering_params)
      end
    end
  end

  def initialize(user, event_cancellation_plan_item)
    @user = user
    @event_cancellation_plan_item = event_cancellation_plan_item
  end

  def index?
    user&.super_admin? || user&.digital_store_admin? || user&.india_admin?
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
