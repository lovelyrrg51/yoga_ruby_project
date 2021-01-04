class AddDetailsToEvent < ActiveRecord::Migration
  def change
    add_column :events, :registrations_recipients, :text
  end
end
