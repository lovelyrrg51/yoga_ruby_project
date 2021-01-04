class RoleDependencyPolicy < ApplicationPolicy
  attr_reader :role_dependency

  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = {})
      scope.filter(filtering_params)
    end
  end

  def initialize(user, role_dependency)
    super(user, role_dependency.try(:role_dependable))
    @role_dependency = role_dependency
  end

  def index?
    permissions[:super_admin] || permissions[:event_admin] || india_admin
  end

  def create?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index?
  end

end
