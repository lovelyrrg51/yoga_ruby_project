class Api::V1::ShivyogClub::SyClubDigitalArrangementDetailPolicy < Api::V1::ApplicationPolicy
  attr_reader :sy_club_digital_arrangement_detail, :is_club_creator
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  
  def initialize(user, sy_club_digital_arrangement_detail)
    @sy_club_digital_arrangement_detail = sy_club_digital_arrangement_detail
    @is_club_creator = (user == sy_club_digital_arrangement_detail.sy_club.user)
    super(user, sy_club_digital_arrangement_detail.sy_club)

  end
    
  def create?
    # if user is super admin
    user.super_admin? || permissions[:country_admin] || is_club_creator
  end
  
  def update?
    # if user is super admin
    user.super_admin? || permissions[:country_admin] || is_club_creator
  end
  
  def destroy?
    # if user is super admin
    user.super_admin?
  end
end
