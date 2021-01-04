class AddRequestParamsToTransactionLog < ActiveRecord::Migration
  def change
    add_column :transaction_logs, :request_params, :text
  end
end
