class AddToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :collection_name, :string
    add_column :collections, :collection_description, :string
    add_column :collections, :collection_long_description, :text
  end
end
