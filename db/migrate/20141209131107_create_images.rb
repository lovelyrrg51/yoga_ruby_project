class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :name
      t.string :s3_url
      t.string :s3_path
      t.boolean :is_secure
      t.string :s3_bucket
      t.references :imageable, polymorphic: true

      t.timestamps
    end
  end
end
