class Api::V1::TaxTypePolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :tax_type
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  
  def initialize(user, tax_type)
    @user = user
    @tax_type = tax_type
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
    user.super_admin? or user.digital_store_admin? or user.india_admin? or user.event_admin?
  end
  
end
