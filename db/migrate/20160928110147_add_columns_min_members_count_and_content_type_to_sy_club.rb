class AddColumnsMinMembersCountAndContentTypeToSyClub < ActiveRecord::Migration
  def change
    add_column :sy_clubs, :min_members_count, :integer, default: 10
    add_column :sy_clubs, :content_type, :string, default: 'english'
  end
end
