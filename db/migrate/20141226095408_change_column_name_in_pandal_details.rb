class ChangeColumnNameInPandalDetails < ActiveRecord::Migration
  def change
    rename_column :pandal_details, :length, :len
  end
end
