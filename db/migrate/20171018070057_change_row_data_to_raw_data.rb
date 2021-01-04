class ChangeRowDataToRawData < ActiveRecord::Migration[5.0]
  def change
    rename_column :authorizations, :row_data, :raw_data
  end
end
