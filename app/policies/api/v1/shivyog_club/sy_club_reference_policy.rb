class Api::V1::ShivyogClub::SyClubReferencePolicy < Api::V1::ApplicationPolicy
  attr_reader :sy_club_reference, :is_club_creator
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end
  
  def initialize(user, sy_club_reference)
    @sy_club_reference = sy_club_reference
    @is_club_creator = (user == sy_club_reference.sy_club.user)
    super(user, sy_club_reference.sy_club)
  end
    
  def create?
    # if user is super admin
    user.present? and (user.super_admin? or user.club_admin?  or permissions[:country_admin] or is_club_creator)
  end
  
  def update?
    # if user is super admin
    user.present? and (user.super_admin? or user.club_admin? or permissions[:country_admin] or is_club_creator)
  end
  
  def destroy?
    # if user is super admin
    user.present? and (user.super_admin? or user.club_admin?)
  end
end
