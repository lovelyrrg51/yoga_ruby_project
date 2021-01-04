class AddPriorityToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :priority, :integer
  end
end
