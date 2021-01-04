class AddAuthorToDigitalAsset < ActiveRecord::Migration
  def change
    add_column :digital_assets, :author, :string
    add_column :digital_assets, :is_for_sale_on_store, :boolean, :default => true
  end
end
