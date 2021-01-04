class ShivyogTeachingPolicy < ApplicationPolicy
  attr_reader :user, :shivyog_teaching
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      filtering_params.select!{|k,v| v.present?}
      if( filtering_params.present? )
        scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end

  def initialize(user, shivyog_teaching)
    @user = user
    @shivyog_teaching = shivyog_teaching
  end

  def index?
    # if user is super admin or store admin or india admin
    user.super_admin? || user.digital_store_admin? || user.india_admin?
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
