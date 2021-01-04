class ChangeCollectionDescriptionInCollection < ActiveRecord::Migration
  def change
    change_column :collections, :collection_description, :text
  end
end
