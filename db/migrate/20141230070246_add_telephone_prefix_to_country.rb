class AddTelephonePrefixToCountry < ActiveRecord::Migration
  def change
    add_column :db_countries, :telephone_prefix, :string
  end
end
