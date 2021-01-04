class AddDefaultValueMemberCountToSyClub < ActiveRecord::Migration
  def change
    change_column :sy_clubs, :members_count, :integer, default: 0
  end
end
