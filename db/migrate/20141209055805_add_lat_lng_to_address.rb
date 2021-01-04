class AddLatLngToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :lat, :decimal, precision: 16, scale: 8
    add_column :addresses, :lng, :decimal, precision: 16, scale: 8
  end
end
