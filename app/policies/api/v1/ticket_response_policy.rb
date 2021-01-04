class Api::V1::TicketResponsePolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :ticket_response, :ticket
  
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end
  
  def initialize(user, ticket_response)
    @user = user
    @ticket_response = ticket_response
    @ticket = ticket_response.ticket
  end
  
  def create?
    # if user is super admin or store admin
    # if user created the ticket
    # if user is assigned this ticket
    # if user belongs to the ticket's group
    user.super_admin? or user.digital_store_admin? or ticket.user == user or ticket.assigned_user == user or user.ticket_groups.include?(ticket.ticket_group)
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
