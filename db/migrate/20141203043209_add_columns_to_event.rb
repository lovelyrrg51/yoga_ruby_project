class AddColumnsToEvent < ActiveRecord::Migration
  def change
    add_reference :events, :event_category, index: true
    add_reference :events, :event_type, index: true
    add_column :events, :payment_category, :integer
    add_column :events, :total_capacity, :integer
    add_column :events, :contact_email, :string
    add_column :events, :website, :string
 
    # event_category_id removed in migration 20141216083256
#    add_foreign_key :events, :event_categories
    add_foreign_key :events, :event_types
  end
end
