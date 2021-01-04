# frozen_string_literal: true

class OtherSpiritualAssociationPolicy < ApplicationPolicy
  attr_reader :user, :other_spiritual_association
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin? or user.digital_store_admin?
        scope.all
      else
        []
      end
    end
  end

  def initialize(user, other_spiritual_association)
    @user = user
    @other_spiritual_association = other_spiritual_association
  end

  def show?
    user.super_admin? || user.digital_store_admin?
  end

  def create?
    user.super_admin? || user.digital_store_admin? ||
      user.sadhak_profile == other_spiritual_association.sadhak_profile ||
      user.sadhak_profiles.include?(other_spiritual_association.sadhak_profile)
  end

  def update?
    create?
  end

  def destroy?
    show?
  end
end
