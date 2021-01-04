# frozen_string_literal: true

class AdvanceProfilePolicy < ApplicationPolicy
  attr_reader :user, :advance_profile
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin? || user.photo_approval_admin?
        scope.all
      else
        []
      end
    end
  end

  def initialize(user, advance_profile)
    @user = user
    @advance_profile = advance_profile
  end

  def show?
    user&.super_admin? || user&.digital_store_admin? || user&.india_admin?
  end

  def create?
    true
  end

  def update?
    show? || user.sadhak_profile == advance_profile.sadhak_profile ||
      user.sadhak_profiles.include?(advance_profile.sadhak_profile)
  end

  def destroy?
    show?
  end
end
