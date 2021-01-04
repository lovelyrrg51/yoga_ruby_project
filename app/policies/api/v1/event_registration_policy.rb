class Api::V1::EventRegistrationPolicy < Api::V1::ApplicationPolicy
  attr_reader :event_registration
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
    @event_registration = event_registration
    super(user, event_registration.try(:event))
  end

  # if user is super admin or store admin
  def show?
    user.super_admin? or user.digital_store_admin?
  end

  # if user is super admin or store admin or india admin
  def generate_csv?
    user.present? and (user.super_admin? or user.event_admin? or permissions[:per_event_admin] or permissions[:country_admin])
  end

  def generate_file?
    user.present? and (user.super_admin? or user.event_admin?)
  end

end
