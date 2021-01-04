class Addfieldtoauthorizations < ActiveRecord::Migration[5.0]
  def change
    add_column :authorizations, :user_id, :integer
    add_column :authorizations, :email, :string
  end
end
