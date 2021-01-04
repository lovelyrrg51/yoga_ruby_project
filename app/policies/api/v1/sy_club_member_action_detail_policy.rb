class Api::V1::SyClubMemberActionDetailPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :sy_club_member_action_detail
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.present?
        scope.filter(filtering_params)
      elsif user.present? and (user.super_admin? or user.club_admin?)
        scope.all
      else
        {}
      end
    end
  end

  def initialize(user, sy_club_member_action_detail)
    @user = user
    @sy_club_member_action_detail = sy_club_member_action_detail
  end

  def create?
    # if user is super admin or club admin or valid requester
    user.present? and (user.super_admin? or user.club_admin?)
  end

  def update?
    # if user is super admin or club admin or valid requester
    user.present?
  end

  def destroy?
    # if user is super admin or club admin
    user.present? and (user.super_admin? or user.club_admin?)
  end
end
