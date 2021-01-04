class Api::V1::SubSourceTypePolicy < Api::V1::ApplicationPolicy
	attr_reader :user, :sub_source_type
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      return filtering_params.nil? ? scope.all : scope.filter(filtering_params)
    end
  end

  def initialize(user, sub_source_type)
    @user = user
    @sub_source_type = sub_source_type
  end
    
  def create?
    # if user is super admin or india admin
    user.present? and (user.super_admin? or user.india_admin?)
  end
  
  def update?
    # if user is super admin or india admin
    user.present? and (user.super_admin? or user.india_admin?)
  end
  
  def destroy?
    # if user is super admin or india admin
    user.present? and (user.super_admin? or user.india_admin?)
  end

  def show?
  	# if user is super admin or india admin
    user.present? and (user.super_admin? or user.india_admin?)
  end
end
