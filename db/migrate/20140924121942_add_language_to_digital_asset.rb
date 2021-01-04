class AddLanguageToDigitalAsset < ActiveRecord::Migration
  def change
    add_column :digital_assets, :language, :string
  end
end
