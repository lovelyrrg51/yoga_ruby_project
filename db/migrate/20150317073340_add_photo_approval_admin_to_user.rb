class AddPhotoApprovalAdminToUser < ActiveRecord::Migration
  def change
    add_column :users, :photo_approval_admin, :boolean,
    :default => false
  end
end
