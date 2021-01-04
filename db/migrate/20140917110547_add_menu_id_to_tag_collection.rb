class AddMenuIdToTagCollection < ActiveRecord::Migration
  def change
    add_column :tag_collections, :menu_id, :integer, default: 0
  end
end
