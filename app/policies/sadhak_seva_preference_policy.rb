# frozen_string_literal: true

class SadhakSevaPreferencePolicy < ApplicationPolicy
  attr_reader :user, :sadhak_seva_preference
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin? || user.digital_store_admin?
        scope.all
      else
        []
      end
    end
  end

  def initialize(user, sadhak_seva_preference)
    @user = user
    @sadhak_seva_preference = sadhak_seva_preference
  end

  def show?
    user.super_admin? || user.digital_store_admin?
  end

  def create?
    user.super_admin? || user.digital_store_admin? ||
      user.sadhak_profile == sadhak_seva_preference.sadhak_profile ||
      user.sadhak_profiles.include?(sadhak_seva_preference.sadhak_profile)
  end

  def update?
    create?
  end

  def destroy?
    show?
  end
end
