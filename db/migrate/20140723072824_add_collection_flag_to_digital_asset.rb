class AddCollectionFlagToDigitalAsset < ActiveRecord::Migration
  def change
    add_column :digital_assets, :is_collection, :boolean, :default => false
  end
end
