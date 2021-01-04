class AddEmailAndContactNumberToSyClub < ActiveRecord::Migration
  def change
    add_column :sy_clubs, :contact_details, :string
    add_column :sy_clubs, :email, :string
    add_column :sy_clubs, :status, :integer
  end
end
