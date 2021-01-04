class Api::V1::OtherSpiritualAssociationPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :other_spiritual_association
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin? or user.digital_store_admin?
        scope.all
      else
        []
      end
    end
  end
  
  def initialize(user, other_spiritual_association)
    @user = user
    @other_spiritual_association = other_spiritual_association
  end
  
  def show?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
  
  def create?
    # if user is super admin or store admin or sadhak profile of details belongs to current user
    user.super_admin? or user.digital_store_admin? or user.sadhak_profile == other_spiritual_association.sadhak_profile or user.sadhak_profiles.include?(other_spiritual_association.sadhak_profile)
  end
  
  def update?
    # if user is super admin or store admin or sadhak profile of details belongs to current user
    user.super_admin? or user.digital_store_admin? or user.sadhak_profile == other_spiritual_association.sadhak_profile or user.sadhak_profiles.include?(other_spiritual_association.sadhak_profile)
  end
  
  def destroy?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
end
