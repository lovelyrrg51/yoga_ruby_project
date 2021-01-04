class SyEventCompaniesPolicy < ApplicationPolicy
	attr_reader :user, :sy_event_companies
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      filtering_params.select! { |k,v| v.present? }
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end

  def initialize(user, sy_event_companies)
    @user = user
    @sy_event_companies = sy_event_companies
  end

  def index?
    # if user is super admin or club admin
    user&.super_admin? || user&.club_admin?
  end

  def new?
    index?
  end

  def create?
    index?
  end

  def edit?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index?
  end
end
