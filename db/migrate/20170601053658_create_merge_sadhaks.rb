class CreateMergeSadhaks < ActiveRecord::Migration[5.0]
  def change
    create_table :merge_sadhaks do |t|
      t.string :primary_sadhak_id
      t.string :secondary_sadhak_id
      t.string :merge_ref_number
      t.text :meta_data
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end


