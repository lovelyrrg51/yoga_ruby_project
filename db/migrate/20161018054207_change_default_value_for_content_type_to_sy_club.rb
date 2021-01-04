class ChangeDefaultValueForContentTypeToSyClub < ActiveRecord::Migration
  def change
    change_column :sy_clubs, :content_type, :string, default: 'hindi'
  end
end
