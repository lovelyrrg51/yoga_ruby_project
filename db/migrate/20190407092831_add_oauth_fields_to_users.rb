class AddOauthFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :oauth_provider, :string
    add_column :users, :oauth_uid, :string
    add_index :users, :oauth_uid, where: "oauth_uid IS NOT NULL"
    add_column :users, :oauth_image, :string
  end
end
