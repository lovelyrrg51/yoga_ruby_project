# frozen_string_literal: true

class HdfcConfigPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def initialize(user, hdfc_config)
    @user = user
    @hdfc_config = hdfc_config
  end

  def index?
    user.super_admin? || user.event_admin?
  end

  def create?
    index?
  end

  def new?
    index?
  end

  def edit?
    index?
  end

  def update?
    index?
  end

  def destroy?
    user.super_admin? || user.digital_store_admin? || user.event_admin?
  end

  end
