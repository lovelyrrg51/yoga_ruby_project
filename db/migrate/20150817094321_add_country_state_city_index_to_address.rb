class AddCountryStateCityIndexToAddress < ActiveRecord::Migration
  def change
    add_index :addresses, :country_id
    add_index :addresses, :state_id
    add_index :addresses, :city_id
  end
end
