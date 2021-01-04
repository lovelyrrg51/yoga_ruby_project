class AddColumnSyPgIdToTransactionLog < ActiveRecord::Migration[4.2]
  def change
    add_column :transaction_logs, :sy_pg_id, :integer
  end
end
