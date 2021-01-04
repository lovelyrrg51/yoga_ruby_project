class CreateTransactionLogs < ActiveRecord::Migration
  def change
    create_table :transaction_logs do |t|
      t.integer :transaction_loggable_id
      t.string :transaction_loggable_type
      t.text :gateway_request_object
      t.text :gateway_response_object
      t.integer :transaction_type
      t.string :gateway_transaction_id
      t.text :other_detail
      t.integer :gateway_type
      t.string :gateway_name
      t.integer :status, default: 0

      t.timestamps
    end
    add_index :transaction_logs, [:transaction_loggable_id, :transaction_loggable_type], name: 'index_transaction_logs_on_id_type'
  end
end
