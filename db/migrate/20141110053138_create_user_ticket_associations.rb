class CreateUserTicketAssociations < ActiveRecord::Migration
  def change
    create_table :user_ticket_associations do |t|
      t.integer :ticket_id
      t.integer :user_id
      t.foreign_key :tickets, dependent: :delete
      t.foreign_key :users, dependent: :delete
      
      t.timestamps
    end
  end
end
