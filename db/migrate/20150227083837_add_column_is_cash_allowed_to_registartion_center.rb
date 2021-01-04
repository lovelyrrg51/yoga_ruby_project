class AddColumnIsCashAllowedToRegistartionCenter < ActiveRecord::Migration
  def change
    add_column :registration_centers, :is_cash_allowed, :boolean, :default => false
  end
end
