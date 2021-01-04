class AddIndexToCollection < ActiveRecord::Migration
  def change
    add_index :collections, :source_asset_id
  end
end
