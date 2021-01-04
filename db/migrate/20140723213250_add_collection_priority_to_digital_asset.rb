class AddCollectionPriorityToDigitalAsset < ActiveRecord::Migration
  def change
    add_column :digital_assets, :collection_priority, :integer
  end
end
