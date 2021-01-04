class AddStartDateAndEndDateToRegistrationCenter < ActiveRecord::Migration
  def change
    add_column :registration_centers, :start_date, :string
    add_column :registration_centers, :end_date, :string
  end
end
