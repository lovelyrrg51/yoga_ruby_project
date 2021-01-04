class Remanefieldfromauthorizations < ActiveRecord::Migration[5.0]
  def change
    rename_column :authorizations, :oauth_token, :token
  end
end
