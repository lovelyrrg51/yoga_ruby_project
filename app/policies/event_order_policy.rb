class EventOrderPolicy < ApplicationPolicy
  attr_reader :event_order
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.present?
         scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end

  def initialize(user, event_order)
    @event_order = event_order
    super(user, event_order.try(:event))
  end

  def show?
    user.present? and (user.super_admin? or user.digital_store_admin? or (user.event_orders.include? event_order) or user.india_admin?)
  end

  def create?
    user.present? && (user.super_admin? or user.event_admin? or user.india_admin? or user.is_country_admin? or permissions[:per_event_admin])
  end

  def update?
    # if user is super admin or store admin or india admins
    user.present? and (user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin? or permissions[:country_admin])
  end

  def destroy?
    # if user is super admin or store admin or india admins
    user.present? and (user.super_admin? or user.digital_store_admin? or user.india_admin?)
  end

  def payment_refunds?
    user.present? && (user.super_admin? || user.event_admin? || permissions[:india_admin] || permissions[:country_admin] || permissions[:per_event_admin])
  end

  def clp_refund?
    payment_refunds?
  end

  def generate_csv?
    # if user is super admin or store admin or india admin
   user.present? and (user.super_admin? or user.event_admin? or permissions[:country_admin] or permissions[:per_event_admin])
  end

  def resend_pre_approval_email?
    user.present? and (user.super_admin? or user.event_admin? or (user.india_admin? and user.sadhak_profile.address.present? and user.sadhak_profile.address.country_id == 113 and @event_order.event.address.present? and @event_order.event.address.country_id == 113) or permissions[:country_admin] or permissions[:per_event_admin])
  end

  def edit_before_pay?
    user.present? and (user.super_admin? or user.event_admin? or (user.india_admin? and user.sadhak_profile.try(:address).present? and user.sadhak_profile.address.country_id == 113 and @event_order.event.try(:address).present? and @event_order.event.address.country_id == 113))
  end

  def can_refund_1k_shivir?

    is_access = true

    event_type_check = ["Shiv Yog Shambhavi(1K) Shivir", "Shiv Yog Sri Vidya(1K) Shivir"].include?(event_order.try(:event).try(:event_type).try(:name))

    is_access = user.present? && (user.event_admin? or user.india_admin? or user == event_order.try(:event).try(:creator_user)) if event_type_check

    is_access
  end

  def can_transfer_1k_shivir_to_any_shivir_or_vice_versa?
    can_refund_1k_shivir?
  end

  def can_perform_registration_upgrade?
    can_refund_1k_shivir?
  end

  def pay?
    create?
  end

  def update_status?
    user.super_admin? || user.event_admin?
  end

  def bulk_update_event_order_status?
    user.super_admin? || user.event_admin?
  end

  def resend_transaction_receipt_email?
    resend_pre_approval_email?
  end
end
