class AddStatusToPgSyddTransaction < ActiveRecord::Migration
  def change
    add_column :pg_sydd_transactions, :status, :integer
  end
end
