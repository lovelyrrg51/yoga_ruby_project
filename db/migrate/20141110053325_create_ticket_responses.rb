class CreateTicketResponses < ActiveRecord::Migration
  def change
    create_table :ticket_responses do |t|
      t.integer :ticket_id
      t.integer :user_id
      t.text :response
      t.foreign_key :tickets, dependent: :delete
      t.foreign_key :users, dependent: :delete
      
      t.timestamps
    end
  end
end
