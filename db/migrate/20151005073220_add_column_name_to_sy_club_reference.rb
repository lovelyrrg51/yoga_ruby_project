class AddColumnNameToSyClubReference < ActiveRecord::Migration
  def change
    add_column :sy_club_references, :name, :string
  end
end
