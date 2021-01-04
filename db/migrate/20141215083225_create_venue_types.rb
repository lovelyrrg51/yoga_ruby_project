class CreateVenueTypes < ActiveRecord::Migration
  def change
    create_table :venue_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
