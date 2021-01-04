class CreateSpiritualPracticeFrequentSadhnaTypeAssociations < ActiveRecord::Migration
  def change
    create_table :spiritual_practice_frequent_sadhna_type_associations do |t|
      t.integer :spiritual_practice_id
      t.integer :frequent_sadhna_type_id

      t.timestamps
    end
  end
end
