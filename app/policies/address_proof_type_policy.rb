# frozen_string_literal: true

class AddressProofTypePolicy < ApplicationPolicy
  attr_reader :user, :address_proof_type
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

  def initialize(user, address_proof_type)
    @user = user
    @address_proof_type = address_proof_type
  end

  def index?
    user.super_admin? || user.photo_approval_admin? || user.india_admin?
  end

  def new?
    index?
  end

  def create?
    index?
  end

  def edit?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index?
  end
end
