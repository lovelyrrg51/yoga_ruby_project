class CreateExtensionDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :extension_details do |t|

      t.text :downloaded_assets
      t.integer :sadhak_profile_id

      t.timestamps
    end
  end
end
