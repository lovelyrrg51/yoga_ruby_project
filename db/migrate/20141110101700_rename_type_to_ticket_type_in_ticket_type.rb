class RenameTypeToTicketTypeInTicketType < ActiveRecord::Migration
  def change
    rename_column :ticket_types, :type, :ticket_type
  end
end
