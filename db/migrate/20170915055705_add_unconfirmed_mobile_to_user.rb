class AddUnconfirmedMobileToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :unconfirmed_mobile, :string
  end
end
