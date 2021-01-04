class AddIndexToTagCollection < ActiveRecord::Migration
  def change
    add_index :tag_collections, :name
    add_index :tag_collections, :menu_id
  end
end
