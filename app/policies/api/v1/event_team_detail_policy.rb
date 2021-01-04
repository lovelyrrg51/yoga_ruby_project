class Api::V1::EventTeamDetailPolicy < Api::V1::ApplicationPolicy
  attr_reader :event_team_detail, :is_event_creator
  
  
  def initialize(user, event_team_detail)
    @event_team_detail = event_team_detail
    @is_event_creator = (user == event_team_detail.event.creator_user)
    super(user, event_team_detail.try(:event))
  end
    
  def create?
    # if user is super admin or event admin or country admin
    user.super_admin? or user.event_admin? or user.india_admin? or permissions[:country_admin] or user.india_admin? or is_event_creator or permissions[:per_event_admin]
  end
  
  def update?
   # if user is super admin or event admin or country admin
    user.super_admin? or user.event_admin? or user.india_admin? or permissions[:country_admin] or user.india_admin? or is_event_creator or permissions[:per_event_admin]
  end
  
  def destroy?
   # if user is super admin or event admin or country admin
    user.super_admin? or user.event_admin? or user.india_admin? or permissions[:country_admin] or user.india_admin? or is_event_creator or permissions[:per_event_admin]
  end
  
end
