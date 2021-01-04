class DigitalAssetSecretPolicy
  attr_reader :user, :digital_asset, :digital_asset_secret

  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin? or user.digital_store_admin?
        scope.all
      end
    end
  end
  
  def initialize(user, digital_asset)
    @user = user
    @digital_asset = digital_asset
  end
  
  def show_secret_data?
    if digital_asset.is_collection
      return true
    end
    
    if (user.user_groups & digital_asset.user_groups).count > 0
      is_owned = true
    elsif user.digital_assets.find_by(id: digital_asset.id) == nil
      is_owned = false
    else
      is_owned = true
    end
    user.super_admin? or user.digital_store_admin? or user.club_admin? or is_owned
  end

  
  def show_all_secrets?
    user and (user.super_admin? or user.digital_store_admin? or user.club_admin?)
  end
  
  def create?
    user.super_admin? or user.digital_store_admin? or user.club_admin?
  end

  def update?
    user.super_admin? or user.digital_store_admin? or user.club_admin?
  end

end