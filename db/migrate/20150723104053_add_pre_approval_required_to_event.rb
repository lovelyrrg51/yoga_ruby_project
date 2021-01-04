class AddPreApprovalRequiredToEvent < ActiveRecord::Migration
  def change
    add_column :events, :pre_approval_required, :boolean, :default => :false
  end
end
