class Api::V1::UserGroupPolicy
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
    user.super_admin? or user.digital_store_admin?  or user.group_admin?
  end
  
  def show?
    user.super_admin? or user.digital_store_admin?  or user.group_admin? or user.user_groups.include?(user_group)
  end
  
  def create?
    user.super_admin? or user.digital_store_admin?  or user.group_admin?
  end
  
  def update?
    user.super_admin? or user.digital_store_admin?  or user.group_admin?
  end
  
  def destroy?
    user.super_admin? or user.digital_store_admin?  or user.group_admin?
  end
end
