class AddIsDeletedToTaxType < ActiveRecord::Migration
  def change
    add_column :tax_types, :is_deleted, :boolean, default: false
  end
end
