class AddIsDeletedToEventTaxTypeAssociation < ActiveRecord::Migration
  def change
    add_column :event_tax_type_associations, :is_deleted, :boolean, default: false
  end
end
