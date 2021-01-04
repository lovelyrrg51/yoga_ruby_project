class RemoveColumnFromSubSourceType < ActiveRecord::Migration
  def change
    remove_column :sub_source_types, :alternative_source, :text
  end
end
