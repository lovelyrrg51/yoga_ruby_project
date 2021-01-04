class AddColumnMetaDataToSyClub < ActiveRecord::Migration
  def change
    add_column :sy_clubs, :metadata, :text
  end
end
