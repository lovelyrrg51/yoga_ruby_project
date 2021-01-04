class RemoveFieldsFromDigitalAsset < ActiveRecord::Migration
  def change
    remove_column :digital_assets, :asset_file_name
    remove_column :digital_assets, :asset_vimeo_embed_link
    remove_column :digital_assets, :asset_dl_url
  end
end
