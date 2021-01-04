class Api::V1::DigitalAssetPolicy
  attr_reader :user, :digital_asset

  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = {})
      if user.present?
        if user.super_admin? or user.digital_store_admin? or user.club_admin?
          scope.all
        else
          language = user.try(:sadhak_profile).try(:sy_clubs).try(:first).try(:content_type).to_s.split(',')
          scope.filter(filtering_params.merge({published_on: Date.today.to_s, expires_at: Date.today.to_s, language: language}))
        end
      else
        DigitalAsset.where(id: nil)
      end
    end
  end
  
  def initialize(user, digital_asset)
    @user = user
    @digital_asset = digital_asset
  end

  def create?
    user.present? and (user.super_admin? or user.digital_store_admin? or user.club_admin?)
  end
  
  def update?
    user.present? and (user.super_admin? or user.digital_store_admin? or user.club_admin?)
  end
  
  def destroy?
    user.present? and (user.super_admin? or user.digital_store_admin? or user.club_admin?)
  end
  
  def show_video_id?
    # check if user is not logged in
    if user.nil?
      display_secret_id = false
    # check if user is super admin or store admin or
    elsif user.super_admin? or user.digital_store_admin? or user.club_admin?
      display_secret_id = true
    # check if asset is for sale and price of asset is 0
    elsif digital_asset.price == 0 and digital_asset.is_for_sale_on_store?
      display_secret_id = true
    # user is logged in
    else
      # check if user owns the digital asset
      if !user.digital_assets.nil? and !user.digital_assets.find_by(id: digital_asset.id).nil?
        display_secret_id = true
      # check if user and asset belong to same user group
      elsif !display_secret_id and !digital_asset.is_for_sale_on_store? and (user.user_groups & digital_asset.user_groups).count > 0
        display_secret_id = true
      else
        display_secret_id = false
      end
    end
      
    # user and asset fall under same user group
    # if (user.user_groups & digital_asset.user_groups).count > 0
    #   display_secret_id = true
    # elsif digital_asset.price == 0
    #   display_secret_id = true
    # elsif user.nil? or user.digital_assets.nil?
    #   display_secret_id = false
    # elsif user.digital_assets.find_by(id: digital_asset.id) == nil
    #   display_secret_id = false
    # else
    #   display_secret_id = true
    # end
    display_secret_id
  end
  
  def download?
    user.present? and (user.super_admin? or user.digital_store_admin? or user.club_admin?)
  end
end
