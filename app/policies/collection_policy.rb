# frozen_string_literal: true

class CollectionPolicy < ApplicationPolicy
  attr_reader :user, :collection, :current_sadhak_profile
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      filtering_params.select! { |_, v| v.present? }
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.all
      end
    end
  end

  def initialize(user, collection)
    @user = user
    @collection = collection
    @current_sadhak_profile = user.sadhak_profile
  end

  def create?
    user.super_admin?
  end

  def index?
    user.super_admin?
  end

  def edit?
    user.super_admin?
  end

  def update?
    user.super_admin?
  end

  def destroy?
    user.super_admin?
  end

  def create_episodes_collection?
    user.super_admin?
  end

  def shivir_episode_upload_access?
    user.super_admin? || current_sadhak_profile.has_shivir_episode_upload_access?
  end

  def is_shivir_episode_access_admin?
    user.super_admin? || current_sadhak_profile.is_shivir_episode_access_admin?
  end

  def shivir_collections?
    user.super_admin? || current_sadhak_profile.has_shivir_episode_upload_access?
  end

end
