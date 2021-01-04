class SubSourceTypePolicy < ApplicationPolicy
	attr_reader :user, :sub_source_type
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      filtering_params.nil? ? scope.all : scope.filter(filtering_params)
    end
  end

  def initialize(user, sub_source_type)
    @user = user
    @sub_source_type = sub_source_type
  end

  def index?
    # if user is super admin or india admin
    user&.super_admin? or user&.india_admin?
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

  def show?
  	index?
  end
end
