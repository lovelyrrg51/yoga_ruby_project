class AddIndexToDigitalAsset < ActiveRecord::Migration
  def change
    add_index :digital_assets, :collection_id
    # below is already added in migration 20140918062312
    #    add_index :digital_assets, :digital_asset_secret_id
  end
end
