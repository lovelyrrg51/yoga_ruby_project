class Api::V1::ShivyogClub::SyClubPolicy < Api::V1::ApplicationPolicy
  attr_reader :sy_club
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = {})
      scope.filter(filtering_params)
    end
  end
  
  def initialize(user, sy_club)
    # @user = user
    @sy_club = sy_club
    super
  end
    
  def create?
    # if user is super admin or club admin
    user.present? and (user.super_admin? or user.club_admin? or permissions[:country_admin] or user.is_country_admin?)
  end
  
  def update?
    # if user is super admin or club admin
    user.present? and (user.super_admin? or user.club_admin? or permissions[:country_admin] or user == sy_club.user)
  end
  
  def destroy?
    # if user is super admin or club admin
    user.present? and (user.super_admin? or user.club_admin?)
  end

  def admin_transfer?
    user.present? and (user.super_admin? or user.club_admin? or (user.india_admin? and sy_club.try(:address).try(:country_id) == 113))
  end

end
