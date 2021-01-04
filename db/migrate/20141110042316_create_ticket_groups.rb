class CreateTicketGroups < ActiveRecord::Migration
  def change
    create_table :ticket_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
