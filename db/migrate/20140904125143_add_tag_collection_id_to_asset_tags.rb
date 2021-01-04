class AddTagCollectionIdToAssetTags < ActiveRecord::Migration
  def change
    add_column :asset_tags, :tag_collection_id, :integer
  end
end
