class AddCollectionTypeToCollection < ActiveRecord::Migration[5.1]
  def change
    add_column :collections, :collection_type, :integer, default: 0
  end
end
