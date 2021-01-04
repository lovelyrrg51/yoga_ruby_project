class SpecialEventSadhakProfileOtherInfoPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params)
      if filtering_params.present? || user&.super_admin? || user&.event_admin?
        scope.filter(filtering_params)
      else
        []
      end
    end
  end
end
