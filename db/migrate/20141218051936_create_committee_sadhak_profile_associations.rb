class CreateCommitteeSadhakProfileAssociations < ActiveRecord::Migration
  def change
    create_table :committee_sadhak_profile_associations do |t|
      t.references :committee
      t.references :sadhak_profile      
      t.foreign_key :committees, column: :committee_id
      t.foreign_key :sadhak_profiles, column: :sadhak_profile_id
      
      t.timestamps
    end
  end
end
