# frozen_string_literal: true

class GlobalPreferencePolicy < ApplicationPolicy
  attr_reader :user, :global_preference
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = {})
      scope.filter(filtering_params)
    end
  end

  def initialize(user, global_preference)
    @user = user
    @global_preference = global_preference
  end

  def index?
    user.super_admin?
  end

  def create?
    index?
  end

  def edit?
    index?
  end

  def update?
    user.super_admin? || user.digital_store_admin? || user.india_admin?
  end

  def destroy?
    update?
  end
end
