class CreateAssetTags < ActiveRecord::Migration
  def change
    create_table :asset_tags do |t|
      t.string :tag
      t.integer :tag_priority
      t.integer :digital_asset_id
      t.timestamps
    end
  end
end
