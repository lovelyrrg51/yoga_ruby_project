class AddColumnsToDigitalAsset < ActiveRecord::Migration
  def change
    add_column :digital_assets, :available_for, :integer, default: '0'
    add_column :digital_assets, :published_on, :date
  end
end
