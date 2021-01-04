class AddCurrencyToDigitalAsset < ActiveRecord::Migration
  def change
    add_column :digital_assets, :currency, :string, :default => "INR"
  end
end
