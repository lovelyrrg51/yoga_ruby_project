class CreateDsProducts < ActiveRecord::Migration
  def change
    create_table :ds_products do |t|
      t.timestamps
    end
  end
end
