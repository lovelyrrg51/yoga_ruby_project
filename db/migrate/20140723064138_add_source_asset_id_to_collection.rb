class AddSourceAssetIdToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :source_asset_id, :integer 
  end
end
