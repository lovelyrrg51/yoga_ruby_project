class RemoveCollectionLongDescriptionFromCollection < ActiveRecord::Migration
  def change
    remove_column :collections, :collection_long_description
  end
end
