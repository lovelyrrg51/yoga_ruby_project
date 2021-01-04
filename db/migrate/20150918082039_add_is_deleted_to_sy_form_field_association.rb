class AddIsDeletedToSyFormFieldAssociation < ActiveRecord::Migration
  def change
    add_column :sy_form_field_associations, :is_deleted, :boolean, default: false
  end
end
