class TicketPolicy < ApplicationPolicy
  attr_reader :user, :ticket

  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end

  def initialize(user, ticket)
    @user = user
    @ticket = ticket
  end

  def show?
    # if user is super admin or store admin or user created the ticket
    user.super_admin? || user.digital_store_admin? || ticket.user == user
  end

  def update?
    user.super_admin? || user.digital_store_admin?
  end

  def destroy?
    update?
  end

end
