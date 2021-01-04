class Api::V1::ShivyogClub::SyClubMemberPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :sy_club_member
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end
  
  def initialize(user, sy_club_member)
    @user = user
    @sy_club_member = sy_club_member
  end
    
  def create?
    # if user is super admin or club admin
    user.super_admin? or user.club_admin?
  end
  
  def update?
    # if user is super admin or club admin
    user.super_admin? or user.club_admin?
  end
  
  def destroy?
    # if user is super admin or club admin
    user.super_admin? or user.club_admin?
  end
end
