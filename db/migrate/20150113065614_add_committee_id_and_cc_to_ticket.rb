class AddCommitteeIdAndCcToTicket < ActiveRecord::Migration
  def change
    add_column :tickets, :ticket_cc, :text
    add_reference :tickets, :committee, index: true
  end
end
