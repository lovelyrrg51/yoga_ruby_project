class AddPriorityToTagCollection < ActiveRecord::Migration
  def change
    add_column :tag_collections, :priority, :integer
  end
end
