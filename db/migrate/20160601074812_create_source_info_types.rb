class CreateSourceInfoTypes < ActiveRecord::Migration
  def change
    create_table :source_info_types do |t|
      t.string :source_name
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
