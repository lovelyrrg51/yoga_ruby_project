class AddFieldsToSadhakAssetAccessAssociations < ActiveRecord::Migration[5.1]
  def change
    add_column :sadhak_asset_access_associations, :access_from_date, :date
    add_column :sadhak_asset_access_associations, :access_to_date, :date
  end
end
