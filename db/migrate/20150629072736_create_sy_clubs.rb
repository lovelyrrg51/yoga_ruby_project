class CreateSyClubs < ActiveRecord::Migration
  def change
    create_table :sy_clubs do |t|
      t.string :name
      t.integer :club_level
      t.integer :members_count
      t.references :user, index: true
      t.foreign_key :users, column: :user_id
      t.timestamps
    end
  end
end
