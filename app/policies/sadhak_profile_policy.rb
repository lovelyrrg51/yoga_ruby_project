class SadhakProfilePolicy < ApplicationPolicy
  attr_reader :sadhak_profile

  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = {})
      filtering_params.select!{ |k,v| v.present? }
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end

  def initialize(user, sadhak_profile, event = nil)
    super(user, event)
    @sadhak_profile = sadhak_profile
  end

  def permitted_attributes
    if user.present? && (user.super_admin? || user.india_admin?)
      [:status_notes, :profile_photo_status, :photo_id_status]
    else
      []
    end
  end

  def show?
    # if user is super admin or its user's own sadhak profile or its one of the related members sadhak profile
    user and (user.super_admin? or user.sadhak_profile == sadhak_profile or user.sadhak_profiles.include?(sadhak_profile) or user.india_admin? )
  end

  def update?
    # if user is super admin or its user's own sadhak profile or its one of the related members sadhak profile
    user and (user.super_admin? or user.sadhak_profile == sadhak_profile or user.sadhak_profiles.include?(sadhak_profile) or user.india_admin? )
  end

  def generate_file?
    user.present? and (user.super_admin? or user.india_admin?)
  end

  def wp_sadhak_profile?
    # if user is super admin or its user's own sadhak profile or its one of the related members sadhak profile
    user and (user.super_admin? or user.sadhak_profile == sadhak_profile or user.india_admin? )
  end

  def upcoming_shivirs?
    # if user is super admin or its user's own sadhak profile or its one of the related members sadhak profile
    user and (user.super_admin? or user.sadhak_profile == sadhak_profile or user.sadhak_profiles.include?(sadhak_profile) or user.india_admin? )
  end

  def generate_card?
    # if user is super admin or its user's own sadhak profile or its one of the related members sadhak profile
    user and (user.super_admin? or user.sadhak_profile == sadhak_profile or user.sadhak_profiles.include?(sadhak_profile) or user.india_admin? )
  end

  def profile_photo_approve?
    permissions[:super_admin] || permissions[:event_admin] || permissions[:photo_approval_admin] || permissions[:photo_approval_user] || india_admin
  end

  def profile_photo_reject?
    profile_photo_approve?
  end

  def approve_selected?
    permissions[:super_admin] || permissions[:event_admin] || permissions[:photo_approval_admin] || permissions[:photo_approval_user] || india_admin
  end

  def reject_selected?
    approve_selected?
  end

  def capture_picture?
    user.present? && user.super_admin?
  end

  def related_sadhak_profiles?
    user.present?
  end

  def edit?
    user and (user.super_admin? or user.sadhak_profile == sadhak_profile or user.sadhak_profiles.include?(sadhak_profile) or user.india_admin? )
  end

  def new_message?
    user and user.super_admin?
  end

  def send_message?
    user and user.super_admin?
  end

  def reset_user_password?
     user and user.super_admin?
  end

  def reset_and_send_user_password?
    user and user.super_admin?
  end

  def shivir_info?
     user and user.super_admin?
  end

  def forum_info?
     user and user.super_admin?
  end

  def profile_details?
     user and user.super_admin?
  end

  def edit_sadhak_profile_photo?
    user and user.super_admin?
  end

  def update_sadhak_profile_photo?
    user and user.super_admin?
  end

  def sadhak_profile_logs?
    user and user.super_admin?
  end

  def change_sadhak_profile_status?
    user and user.super_admin?
  end

  def update_sadhak_profile_status?
    user and user.super_admin?
  end

  def role_assignment_to_sadhak_profile_user?
     user and user.super_admin?
  end

  def assign_role_to_sadhak_profile_user?
     user and user.super_admin?
  end

  def generate_file?
    user and user.super_admin?
  end

  def destroy?
  	user and user.super_admin?
  end

  def generate_expired_members_file?
    user and (user.super_admin? or user.india_admin? or user.club_admin?)
  end

  def family_profiles?
    user.present?
  end

  def verify?
    user.sadhak_profile == sadhak_profile || user.sadhak_profiles.include?(sadhak_profile)
  end

  def send_email_verification?
    verify?
  end

  def send_mobile_verification?
    verify?
  end

  def resend?
    verify?
  end
end
