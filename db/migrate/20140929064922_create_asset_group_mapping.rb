class CreateAssetGroupMapping < ActiveRecord::Migration
  def change
    create_table :asset_group_mappings do |t|
      t.integer :digital_asset_id, :null => false, :references => [:digital_assets, :id]
      t.integer :user_group_id, :null => false, :references => [:user_groups, :id]
      
      t.timestamps
    end
    add_index :asset_group_mappings, [:digital_asset_id, :user_group_id], :unique => true, :name => 'index_a_g_m_on_digital_asset_id_and_user_group_id'
  end
end
