class AddForeignKeyToPurchasedDigitalAssets < ActiveRecord::Migration
  def up
    execute <<-SQL
        ALTER TABLE purchased_digital_assets
        ADD CONSTRAINT fk_pda_digital_assets
        FOREIGN KEY (digital_asset_id)
        REFERENCES digital_assets(id);

        ALTER TABLE purchased_digital_assets
        ADD CONSTRAINT fk_pda_users
        FOREIGN KEY (user_id)
        REFERENCES users(id);
    SQL
  end
  def down
  	execute <<-SQL
        ALTER TABLE purchased_digital_assets
        DROP CONSTRAINT fk_pda_digital_assets;
        ALTER TABLE purchased_digital_assets
        DROP CONSTRAINT fk_pda_users;
    SQL
  end
end
