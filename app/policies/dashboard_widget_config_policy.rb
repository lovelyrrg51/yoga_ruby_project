# frozen_string_literal: true

class DashboardWidgetConfigPolicy < ApplicationPolicy
  attr_reader :user, :dashboard_widget_config

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, dashboard_widget_config)
    @user = user
    @dashboard_widget_config = dashboard_widget_config
  end

  def index?
    user.super_admin?
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
