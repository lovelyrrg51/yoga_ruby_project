# frozen_string_literal: true

class SpiritualPracticePolicy < ApplicationPolicy
  attr_reader :user, :spiritual_practice
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin? || user.digital_store_admin?
        scope.all
      else
        []
      end
    end
  end

  def initialize(user, spiritual_practice)
    @user = user
    @spiritual_practice = spiritual_practice
  end

  def show?
    user.super_admin? || user.digital_store_admin?
  end

  def create?
    user.super_admin? || user.digital_store_admin? ||
      user.sadhak_profile == spiritual_practice.sadhak_profile ||
      user.sadhak_profiles.include?(spiritual_practice.sadhak_profile)
  end

  def update?
    create?
  end

  def destroy?
    show?
  end
end
