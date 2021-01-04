class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :name
      t.string :file_type
      t.string :file_size
      t.string :s3_url
      t.string :s3_path
      t.string :s3_bucket
      t.boolean :is_secure
      t.references :attachable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
