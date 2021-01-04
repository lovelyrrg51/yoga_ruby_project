class UserGroupPolicy
  attr_reader :user, :user_group

  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin? or user.digital_store_admin?
        scope.all
      end
    end
  end

  def initialize(user, user_group = nil)
    @user = user
    @user_group = user_group
  end

  def index?
    user.super_admin? || user.digital_store_admin? || user.group_admin?
  end

  def show?
    index? || user.user_groups.include?(user_group)
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
