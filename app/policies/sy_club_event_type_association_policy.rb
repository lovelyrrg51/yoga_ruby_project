# frozen_string_literal: true

class SyClubEventTypeAssociationPolicy < ApplicationPolicy
  attr_reader :user, :sy_club_event_type_association
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end

  def initialize(user, sy_club_event_type_association)
    @user = user
    @sy_club_event_type_association = sy_club_event_type_association
  end

  def create?
    user.super_admin? || user.club_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
