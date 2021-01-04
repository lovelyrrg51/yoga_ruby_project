class ChangeColumnDescriptionTypeToDsShop < ActiveRecord::Migration
  def change
    change_column :ds_shops, :description, :text
  end
end
