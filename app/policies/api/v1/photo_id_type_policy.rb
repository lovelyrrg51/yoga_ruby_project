class Api::V1::PhotoIdTypePolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :photo_id_type
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  def initialize(user, photo_id_type)
    @user = user
    @photo_id_type = photo_id_type
  end
  
  def create?
    # if user is super admin or photo approval admin
    user.super_admin? or user.photo_approval_admin?  or user.india_admin?
  end
  
  def update?
    # if user is super admin or photo approval admin
    user.super_admin? or user.photo_approval_admin?  or user.india_admin?
  end
  
  def destroy?
    # if user is super admin or photo approval admin
    user.super_admin? or user.photo_approval_admin?  or user.india_admin?
  end
end
