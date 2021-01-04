class CreateSubSourceTypes < ActiveRecord::Migration
  def change
    create_table :sub_source_types do |t|
      t.references :source_info_type, index: true
      t.string :sub_source_name
      t.text :alternative_source
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
