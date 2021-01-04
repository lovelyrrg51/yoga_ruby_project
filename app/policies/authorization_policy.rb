class AuthorizationPolicy < ApplicationPolicy

  attr_reader :user, :event_type

  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      filtering_params.select! { |_, v| v.present? }
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end

  def initialize(user, event_type)
    @user = user
    @event_type = event_type
  end

end
