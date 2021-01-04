class AddIsForumOrderToEventOrder < ActiveRecord::Migration
  def change
    add_column :event_orders, :is_club_order, :boolean, default: :false
    add_column :event_orders, :sy_club_id, :integer
  end
end
