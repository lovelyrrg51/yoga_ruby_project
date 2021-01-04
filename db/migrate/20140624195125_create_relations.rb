class CreateRelations < ActiveRecord::Migration
  def change
    create_table :relations do |t|
      t.string :frist_name
      t.string :middle_name
      t.string :last_name
      t.string :profession
      t.string :syid  # for the relation.
      t.string :relationship_type # ie mother, father, brother, sister, son, daughter, etc.
      t.integer :relation_profile_id  # sadhak_profile_id for the relation.
      t.integer :sadhak_profile_id # for the sadhak who owns the relation.
      t.timestamps
    end
  end
end
