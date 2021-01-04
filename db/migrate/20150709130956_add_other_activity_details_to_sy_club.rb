class AddOtherActivityDetailsToSyClub < ActiveRecord::Migration
  def change
    add_column :sy_clubs, :other_activity, :string
    add_column :sy_clubs, :cultural_activities, :string
  end
end
