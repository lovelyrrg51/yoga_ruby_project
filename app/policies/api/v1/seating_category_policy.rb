class Api::V1::SeatingCategoryPolicy
  attr_reader :user, :seating_category

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  
  def initialize(user, seating_category)
    @user = user
    @seating_category = seating_category
  end
  
  def show?
    true
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
