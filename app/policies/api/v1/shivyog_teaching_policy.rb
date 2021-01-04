class Api::V1::ShivyogTeachingPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :shivyog_teaching
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  
  def initialize(user, shivyog_teaching)
    @user = user
    @shivyog_teaching = shivyog_teaching
  end
    
  def create?
    # if user is super admin or store admin or india admin 
    user.super_admin? or user.digital_store_admin? or user.india_admin?
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
