class Api::V1::TicketGroupPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :ticket_group
  
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin? or user.digital_store_admin?
        scope.all
      else
        user.ticket_groups
      end
    end
  end
  
  def initialize(user, ticket_group)
    @user = user
    @ticket_group = ticket_group
  end
  
  def show?
    # if user is super admin or store admin or india admin 
    user.super_admin? or user.digital_store_admin? or user.india_admin?
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
