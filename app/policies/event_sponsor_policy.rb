class EventSponsorPolicy < ApplicationPolicy
  attr_reader :user, :event_sponsor
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end
  
  def initialize(user, event_sponsor)
    @user = user
    @event_sponsor = event_sponsor
  end
  
  def create?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin? or (user == event.creator_user) or user.india_admin?
  end
  
  def update?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin? or (user == event.creator_user) or user.india_admin?
  end
  
  def destroy?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin? or user.india_admin?
  end
end
