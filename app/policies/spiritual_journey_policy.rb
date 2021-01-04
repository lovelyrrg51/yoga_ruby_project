# frozen_string_literal: true

class SpiritualJourneyPolicy < ApplicationPolicy
  attr_reader :user, :spiritual_journey
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin? or user.digital_store_admin?
        scope.all
      else
        []
      end
    end
  end

  def initialize(user, spiritual_journey)
    @user = user
    @spiritual_journey = spiritual_journey
  end

  def show?
    user.super_admin? || user.digital_store_admin?
  end

  def create?
    user.super_admin? || user.digital_store_admin? ||
      user.sadhak_profile == spiritual_journey.sadhak_profile ||
      user.sadhak_profiles.include?(spiritual_journey.sadhak_profile)
  end

  def update?
    create?
  end

  def destroy?
    show?
  end
end
