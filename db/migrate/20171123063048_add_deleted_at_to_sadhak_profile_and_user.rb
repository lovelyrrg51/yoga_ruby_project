class AddDeletedAtToSadhakProfileAndUser < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :deleted_at, :datetime
    add_index :sadhak_profiles, :deleted_at
    add_column :users, :deleted_at, :datetime
    add_index :users, :deleted_at
  end
end
