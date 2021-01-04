class CreateAuthorizationTableIfExists < ActiveRecord::Migration[5.0]
  TEXT_BYTES = 1_073_741_823
  def up
    drop_table :authorizations, if_exists: true

    create_table :authorizations do |t|
      t.string :provider
      t.string :uid
      t.string :token
      t.text :row_data, :limit => TEXT_BYTES
      t.datetime :deleted_at
      t.string :email
      t.integer :user_id

      t.timestamps
    end
    add_index :authorizations, :deleted_at

  end

  def down
    drop_table :authorizations, if_exists: true
  end
end
