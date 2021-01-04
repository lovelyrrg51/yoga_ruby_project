class CreateSadhakAssetAccessAssociations < ActiveRecord::Migration[5.1]
  def change
    create_table :sadhak_asset_access_associations do |t|
      t.references :digital_asset, foreign_key: true
      t.string :sadhak_profile_ids

      t.timestamps
    end
  end
end
