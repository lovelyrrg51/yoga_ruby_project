class AddCollectionAndRemoveDigitalAssetFromSadhakAssetAccessAssociations < ActiveRecord::Migration[5.1]
  def self.up
  	remove_reference(:sadhak_asset_access_associations, :digital_asset, index: true, foreign_key: true)
  	add_reference(:sadhak_asset_access_associations, :collection, index:true, foreign_key: true)
  end

  def self.down
  	remove_reference(:sadhak_asset_access_associations, :collection, index: true, foreign_key: true)
  	add_reference(:sadhak_asset_access_associations, :digital_asset, foreign_key: true)
  end
end
