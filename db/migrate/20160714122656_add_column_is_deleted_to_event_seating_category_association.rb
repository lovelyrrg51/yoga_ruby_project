class AddColumnIsDeletedToEventSeatingCategoryAssociation < ActiveRecord::Migration
  def change
    add_column :event_seating_category_associations, :is_deleted, :boolean, default: false
  end
end
