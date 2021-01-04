class Api::V1::ShivyogClub::SyClubEventTypeAssociationPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :sy_club_event_type_association
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end
  
  def initialize(user, sy_club_event_type_association)
    @user = user
    @sy_club_event_type_association = sy_club_event_type_association
  end
    
  def create?
    # if user is super admin or club admin
    user.super_admin? or user.club_admin?
  end
  
  def update?
    # if user is super admin or club admin
    user.super_admin? or user.club_admin?
  end
  
  def destroy?
    # if user is super admin or club admin
    user.super_admin? or user.club_admin?
  end
end
