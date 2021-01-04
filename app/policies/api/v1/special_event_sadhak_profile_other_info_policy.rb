class Api::V1::SpecialEventSadhakProfileOtherInfoPolicy < Api::V1::ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params)
      if filtering_params.present? || (user.present? && (user.super_admin? || user.event_admin?))
        scope.filter(filtering_params)
      else
        []
      end
    end
  end
end
