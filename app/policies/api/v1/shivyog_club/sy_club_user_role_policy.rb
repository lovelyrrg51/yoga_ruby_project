class Api::V1::ShivyogClub::SyClubUserRolePolicy < Api::V1::ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
  def initialize(user, sy_club_user_role)
    @user = user
    @sy_club_user_role = sy_club_user_role
  end
    
  def create?
    # if user is super admin
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
