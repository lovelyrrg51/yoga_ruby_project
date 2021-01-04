class AddStatusToTicketResponse < ActiveRecord::Migration
  def change
    add_column :ticket_responses, :status, :integer
  end
end
