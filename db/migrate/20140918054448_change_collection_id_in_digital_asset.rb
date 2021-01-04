class ChangeCollectionIdInDigitalAsset < ActiveRecord::Migration
  def change
    change_column :digital_assets, :collection_id, :integer, :null => true
  end
end
