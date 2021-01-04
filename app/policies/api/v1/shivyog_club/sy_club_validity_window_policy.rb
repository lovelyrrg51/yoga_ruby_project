class Api::V1::ShivyogClub::SyClubValidityWindowPolicy < Api::V1::ApplicationPolicy
	attr_reader :user, :sy_club_validity_window
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, sy_club_validity_window)
    @user = user
    @sy_club_validity_window = sy_club_validity_window
  end
  
  def create?
    # if user is super admin or store admin or uer.india_admin?
    user.super_admin? or user.digital_store_admin? or uer.india_admin?
  end
  
  def update?
    # if user is super admin or store admin or uer.india_admin? 
    user.super_admin? or user.digital_store_admin? or uer.india_admin?
  end
  
  def destroy?
    # if user is super admin or store admin or uer.india_admin?
    user.super_admin? or user.digital_store_admin? or uer.india_admin?
  end
end
