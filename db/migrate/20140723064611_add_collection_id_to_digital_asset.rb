class AddCollectionIdToDigitalAsset < ActiveRecord::Migration
  def change
    add_column :digital_assets, :collection_id, :integer
  end
end
