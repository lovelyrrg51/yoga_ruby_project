class AddSlugToSadhakProfile < ActiveRecord::Migration[5.0]
  def change
    add_column :sadhak_profiles, :slug, :string
    add_index :sadhak_profiles, :slug, unique: true
  end
end
