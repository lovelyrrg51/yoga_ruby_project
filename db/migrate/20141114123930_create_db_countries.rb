class CreateDbCountries < ActiveRecord::Migration
  def change
    create_table :db_countries do |t|
      t.string :name
      t.string :FIPS104
      t.string :ISO2
      t.string :ISO3
      t.string :ISON
      t.string :internet
      t.string :capital
      t.string :map_reference
      t.string :nationality_singular
      t.string :nationality_plural
      t.string :currency
      t.string :currency_code
      t.integer :population
      t.string :title
      t.text :comment
    end
  end
end
