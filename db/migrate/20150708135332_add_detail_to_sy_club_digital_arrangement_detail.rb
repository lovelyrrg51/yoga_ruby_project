class AddDetailToSyClubDigitalArrangementDetail < ActiveRecord::Migration
  def change
    add_column :sy_club_digital_arrangement_details, :internet_provider, :string
    add_column :sy_club_digital_arrangement_details, :internet_speed, :string
    add_column :sy_club_digital_arrangement_details, :internet_data_plan, :string
  end
end
