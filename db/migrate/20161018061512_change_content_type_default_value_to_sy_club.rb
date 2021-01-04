class ChangeContentTypeDefaultValueToSyClub < ActiveRecord::Migration
  def change
    change_column :sy_clubs, :content_type, :string, default: 'english'
  end
end
