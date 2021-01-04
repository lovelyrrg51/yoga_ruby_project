class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.integer :user_id
      t.integer :assigned_user_id
      t.string :status
      t.integer :ticket_type_id
      t.string :title
      t.text :description
      t.datetime :reopened_at
      t.datetime :closed_at
      t.references :ticketable, polymorphic: true, index: true
      
      t.foreign_key :users
      t.foreign_key :users, column: :assigned_user_id
      t.foreign_key :ticket_types
      
      t.timestamps
    end
  end
end
