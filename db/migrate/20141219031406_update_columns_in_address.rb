class UpdateColumnsInAddress < ActiveRecord::Migration
  def change
    rename_column :addresses, :country, :country_id
    change_column :addresses, :country_id, 'integer USING CAST(country_id AS integer)', :null => true
    
    rename_column :addresses, :state, :state_id
    change_column :addresses, :state_id, 'integer USING CAST(state_id AS integer)', :null => true
    
    rename_column :addresses, :city, :city_id
    change_column :addresses, :city_id, 'integer USING CAST(city_id AS integer)', :null => true
    
    
    add_foreign_key :addresses, :db_countries, :column => :country_id
    add_foreign_key :addresses, :db_states, :column => :state_id
    add_foreign_key :addresses, :db_cities, :column => :city_id
    
  end
end
