class AddForeignKeyToDigitalAssets < ActiveRecord::Migration
  def up
    # already added in migration 20140918062312
#     execute <<-SQL
#     ALTER TABLE digital_assets
# ADD CONSTRAINT fk_digital_assets_digital_asset_secrets
#         FOREIGN KEY (digital_asset_secret_id)
#         REFERENCES digital_asset_secrets(id)
#     SQL
#   end
#   def down
#   	execute <<-SQL
# ALTER TABLE digital_assets
#         DROP CONSTRAINT fk_digital_assets_digital_asset_secrets
#     SQL
   end
end
