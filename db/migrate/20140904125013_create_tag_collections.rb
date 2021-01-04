class CreateTagCollections < ActiveRecord::Migration
  def change
    create_table :tag_collections do |t|
      t.string :name

      t.timestamps
    end
  end
end
