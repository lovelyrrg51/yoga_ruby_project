# frozen_string_literal :true

class EventRegistrationPolicy < ApplicationPolicy
  attr_reader :user, :event_registration
  class Scope < Struct.new(:user, :scope)
     def resolve(filtering_params = {})
      filtering_params.select! { |k, v| v.present?  }
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end

  def initialize(user, event_registration)
    @user = user
    @event_registration = event_registration
  end

  def show?
    user.super_admin? || user.digital_store_admin?
  end

  def generate_csv?
    user&.super_admin? or user&.event_admin?
  end

  def generate_file?
    generate_csv?
  end

  def event_registration_detail?
    user&.super_admin? || user&.india_admin?
  end
end
