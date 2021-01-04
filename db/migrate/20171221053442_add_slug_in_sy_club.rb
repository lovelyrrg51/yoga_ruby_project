class AddSlugInSyClub < ActiveRecord::Migration[5.1]
  def change
    add_column :sy_clubs, :slug, :string
    add_index :sy_clubs, :slug, unique: true
  end
end
