class AddLatLonToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :latitude, :decimal
    add_column :addresses, :longitude, :decimal

    add_index :addresses, [:latitude, :longitude]
  end
end
