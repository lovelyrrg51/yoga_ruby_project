class CreateDbCities < ActiveRecord::Migration
  def change
    create_table :db_cities do |t|
      t.integer :country_id
      t.integer :state_id
      t.string :name
      t.decimal :lat, precision: 16, scale: 8
      t.decimal :lng, precision: 16, scale: 8
      t.string :timezone
      t.integer :dma_id
      t.string :code
      
      t.timestamps
    end
  end
end
