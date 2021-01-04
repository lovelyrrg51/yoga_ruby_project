# frozen_string_literal: true

class ShivyogChangeLogPolicy < ApplicationPolicy
  attr_reader :user, :shivyog_change_log
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if user.present? && user.super_admin?
        if filtering_params.nil?
          scope.all
        else
          scope.filter(filtering_params)
        end
      else
        []
      end
    end
  end

  def initialize(user, shivyog_change_log)
    @user = user
    @shivyog_change_log = shivyog_change_log
  end

  def create?
    # if user is super admin or event admin or india admin
    user.super_admin? || user.event_admin? || user.india_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
