class AddDeletedAtToAuthorizations < ActiveRecord::Migration[5.0]
  def change
    add_column :authorizations, :deleted_at, :datetime
    add_index :authorizations, :deleted_at
  end
end
