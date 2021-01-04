class AddIsDeletedToSyClub < ActiveRecord::Migration
  def change
    add_column :sy_clubs, :is_deleted, :boolean, default: :false
  end
end
