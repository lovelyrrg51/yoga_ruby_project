class AddContentToAttachments < ActiveRecord::Migration[5.1]
  def change
    add_column :attachments, :content, :string
  end
end
