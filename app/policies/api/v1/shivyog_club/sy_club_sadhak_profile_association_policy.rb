class Api::V1::ShivyogClub::SyClubSadhakProfileAssociationPolicy < Api::V1::ApplicationPolicy
  attr_reader :sy_club_sadhak_profile_association, :is_club_creator
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  
  def initialize(user, sy_club_sadhak_profile_association)
    @sy_club_sadhak_profile_association = sy_club_sadhak_profile_association
    @is_club_creator = (user == sy_club_sadhak_profile_association.sy_club.user)
    super(user, sy_club_sadhak_profile_association.sy_club)
  end
    
  def create?
    # if user is super admin or club admin
    user.present? and (user.super_admin? or user.club_admin?) or permissions[:country_admin] or is_club_creator
  end
  
  def update?
    # if user is super admin or club admin
    user.present? and (user.super_admin? or user.club_admin? or permissions[:country_admin] or is_club_creator)
  end
  
  def destroy?
    # if user is super admin or club admin
    user.present? and (user.super_admin? or user.club_admin?)
  end
end
