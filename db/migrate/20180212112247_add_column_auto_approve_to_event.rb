class AddColumnAutoApproveToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :auto_approve, :boolean, default: false
  end
end
