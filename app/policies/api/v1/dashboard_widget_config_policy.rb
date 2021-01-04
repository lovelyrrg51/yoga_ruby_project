class Api::V1::DashboardWidgetConfigPolicy < Api::V1::ApplicationPolicy
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
  
  def create?
    # if user is super admins
    user.super_admin?
  end
  
  def update?
    # if user is super admin
    user.super_admin?
  end
  
  def destroy?
    # if user is super admin
    user.super_admin?
  end
end
