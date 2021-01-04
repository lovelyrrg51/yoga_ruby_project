class AddImageableIndexToImage < ActiveRecord::Migration[5.1]
  def up
    add_index :images, [:imageable_id, :imageable_type]
  end

  def down
    remove_index :images, [:imageable_id, :imageable_type]
  end
end
