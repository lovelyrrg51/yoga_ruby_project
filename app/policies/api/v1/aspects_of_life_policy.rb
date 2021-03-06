class Api::V1::AspectsOfLifePolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :aspects_of_life
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin? or user.digital_store_admin?
        scope.all
      else
        []
      end
    end
  end
  
  def initialize(user, aspects_of_life)
    @user = user
    @aspects_of_life = aspects_of_life
  end
  
  def show?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
  
  def create?
    # if user is super admin or store admin or sadhak profile of details belongs to current user
    user.super_admin? or user.digital_store_admin? or user.sadhak_profile == aspects_of_life.sadhak_profile or user.sadhak_profiles.include?(aspects_of_life.sadhak_profile)
  end
  
  def update?
    # if user is super admin or store admin or sadhak profile of details belongs to current user
    user.super_admin? or user.digital_store_admin? or user.sadhak_profile == aspects_of_life.sadhak_profile or user.sadhak_profiles.include?(aspects_of_life.sadhak_profile)
  end
  
  def destroy?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
end
