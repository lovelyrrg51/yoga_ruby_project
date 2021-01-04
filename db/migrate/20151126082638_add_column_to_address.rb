class AddColumnToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :other_state, :string
    add_column :addresses, :other_city, :string
  end
end
