class CreateSyClubDigitalArrangementDetails < ActiveRecord::Migration
  def change
    create_table :sy_club_digital_arrangement_details do |t|
      t.string :lcd_size
      t.integer :lcd_size
      t.string :lcd_model
      t.integer :speakers_count
      t.string :speaker_model
      t.string :dvd_player_model
      t.string :generator_company
      t.string :inverter_company
      t.boolean :is_laptop_available
      t.references :sy_club, index: true
      t.foreign_key :sy_clubs, column: :sy_club_id
      t.timestamps
    end
  end
end
