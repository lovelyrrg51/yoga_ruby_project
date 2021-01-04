class RenameSeatingCategoryIdToEventSeatingCategoryAssociationIdInEventRegistration < ActiveRecord::Migration
  def change
    rename_column :event_registrations, :seating_category_id, :event_seating_category_association_id
  end
end
