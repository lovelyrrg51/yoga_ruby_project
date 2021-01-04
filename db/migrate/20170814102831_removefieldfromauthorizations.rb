class Removefieldfromauthorizations < ActiveRecord::Migration[5.0]
  def change
    remove_column :authorizations, :oauth_expires_at
    remove_column :authorizations, :name
  end
end
