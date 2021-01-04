class Api::V1::RegistrationCenterUserPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :registration_center_user
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  
  def initialize(user, registration_center_user)
    @user = user
    @registration_center_user = registration_center_user
  end
 
  def create?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
  
  def update?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
  
  def destroy?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
end
