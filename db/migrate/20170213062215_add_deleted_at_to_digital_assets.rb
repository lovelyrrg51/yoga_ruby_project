class AddDeletedAtToDigitalAssets < ActiveRecord::Migration
  def change
    add_column :digital_assets, :deleted_at, :datetime
    add_index :digital_assets, :deleted_at
  end
end
