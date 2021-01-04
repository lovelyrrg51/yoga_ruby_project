class AddDigitalAssetSecretReferenceToDigitalAsset < ActiveRecord::Migration
  def up
	#add a foreign key
    execute <<-SQL
      ALTER TABLE digital_assets
        ADD CONSTRAINT fk_digital_assets_digital_asset_secrets
        FOREIGN KEY (digital_asset_secret_id)
        REFERENCES digital_asset_secrets(id)
    SQL
    add_index :digital_assets, :digital_asset_secret_id
  end
  def down
  	execute <<-SQL
      ALTER TABLE digital_assets
        DROP CONSTRAINT fk_digital_assets_digital_asset_secrets
    SQL
    remove_index :digital_assets, :digital_asset_secret_id
  end
end
