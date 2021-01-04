class Api::V1::GlobalPreferencePolicy < Api::V1::ApplicationPolicy
	attr_reader :user, :global_preference
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = {})
      scope.filter(filtering_params)
    end
  end

  def initialize(user, global_preference)
    @user = user
    @global_preference = global_preference
  end
  
  def create?
    # if user is super admin
    user.super_admin? 
  end
  
  def update?
    # if user is super admin or store admin or india admin
    user.super_admin? or user.digital_store_admin? or user.india_admin?
  end
  
  def destroy?
    # if user is super admin or store admin or india admin
    user.super_admin? or user.digital_store_admin? or user.india_admin?
  end
end
