# frozen_string_literal: true

class EventTypeDigitalAssetAssociationPolicy < ApplicationPolicy
  attr_reader :user, :event_type_digital_asset_association
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end

  def initialize(user, event_type_digital_asset_association)
    @user = user
    @event_type_digital_asset_association = event_type_digital_asset_association
  end

  def show?
    user&.super_admin? || user&.digital_store_admin? || user&.club_admin?
  end

  def create?
    show?
  end

  def update?
    show?
  end

  def destroy?
    show?
  end
end
