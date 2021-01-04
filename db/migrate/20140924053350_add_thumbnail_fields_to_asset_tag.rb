class AddThumbnailFieldsToAssetTag < ActiveRecord::Migration
  def change
    add_column :asset_tags, :thumbnail_url, :string
    add_column :asset_tags, :thumbnail_path, :string
  end
end
