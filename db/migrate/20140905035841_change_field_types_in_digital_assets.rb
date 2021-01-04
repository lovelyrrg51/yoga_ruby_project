class ChangeFieldTypesInDigitalAssets < ActiveRecord::Migration
  def change
    change_column :digital_assets, :asset_description, :text
    change_column :digital_assets, :asset_vimeo_embed_link, :text
  end
end
