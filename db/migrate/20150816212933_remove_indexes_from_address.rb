class RemoveIndexesFromAddress < ActiveRecord::Migration
  def change
    remove_index :addresses, :country_id
    remove_index :addresses, :state_id
    remove_index :addresses, :city_id
  end
end
