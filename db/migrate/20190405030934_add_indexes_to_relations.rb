class AddIndexesToRelations < ActiveRecord::Migration[5.2]
  def change
    add_index :relations, [:user_id, :sadhak_profile_id]
  end
end
