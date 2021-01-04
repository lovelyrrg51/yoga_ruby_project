class RemoveEventCategoryIdFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :event_category_id, :integer
  end
end
