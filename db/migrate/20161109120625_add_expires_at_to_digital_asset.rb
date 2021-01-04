class AddExpiresAtToDigitalAsset < ActiveRecord::Migration
  def change
    add_column :digital_assets, :expires_at, :date
  end
end
