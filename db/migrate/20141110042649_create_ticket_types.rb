class CreateTicketTypes < ActiveRecord::Migration
  def change
    create_table :ticket_types do |t|
      t.string :type
      t.integer :ticket_group_id
      t.foreign_key :ticket_groups, dependent: :delete
      
      t.timestamps
    end
  end
end
