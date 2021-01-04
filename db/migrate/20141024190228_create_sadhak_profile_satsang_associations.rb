class CreateSadhakProfileSatsangAssociations < ActiveRecord::Migration
  def change
    create_table :sadhak_profile_satsang_associations do |t|
      t.integer :sadhak_profile_id
      t.integer :satsang_center_id
      t.timestamps
    end
  end
end
