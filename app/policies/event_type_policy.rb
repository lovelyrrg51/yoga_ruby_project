# frozen_string_literal: true

class EventTypePolicy < ApplicationPolicy
  attr_reader :user, :event_type
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      filtering_params.select! { |k, v| v.present? }
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end

  def initialize(user, event_type)
    @user = user
    @event_type = event_type
  end

  def index?
    user.super_admin? || user.digital_store_admin? || user.india_admin?
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
