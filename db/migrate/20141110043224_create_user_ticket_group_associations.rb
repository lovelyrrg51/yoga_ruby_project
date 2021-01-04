class CreateUserTicketGroupAssociations < ActiveRecord::Migration
  def change
    create_table :user_ticket_group_associations do |t|
      t.integer :ticket_group_id
      t.integer :user_id
      t.foreign_key :ticket_groups, dependent: :delete
      t.foreign_key :users, dependent: :delete
      
      t.timestamps
    end
  end
end
