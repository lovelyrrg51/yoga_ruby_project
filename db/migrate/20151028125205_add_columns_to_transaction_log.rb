class AddColumnsToTransactionLog < ActiveRecord::Migration
  def change
    add_reference :transaction_logs, :user, index: true
    add_column :transaction_logs, :ip, :string
  end
end
