class Api::V1::PhysicalExerciseTypePolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :physical_exercise_type
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  
  def initialize(user, physical_exercise_type)
    @user = user
    @physical_exercise_type = physical_exercise_type
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
