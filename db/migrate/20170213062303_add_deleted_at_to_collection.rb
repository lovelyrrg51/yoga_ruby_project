class AddDeletedAtToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :deleted_at, :datetime
    add_index :collections, :deleted_at
  end
end
