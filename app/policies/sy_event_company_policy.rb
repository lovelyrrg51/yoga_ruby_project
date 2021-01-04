class SyEventCompanyPolicy < ApplicationPolicy
	attr_reader :user, :sy_event_company
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

  def initialize(user, sy_event_company)
    @user = user
    @sy_event_company = sy_event_company
  end

  def index?
    user&.super_admin?
  end

  def create?
    index?
  end

  def new?
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

  def show?
    true
  end
end
