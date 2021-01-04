# frozen_string_literal: true

class RegistrationCenterUserPolicy < ApplicationPolicy
  attr_reader :user, :registration_center_user
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, registration_center_user)
    @user = user
    @registration_center_user = registration_center_user
  end

  def create?
    user.super_admin? || user.digital_store_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
