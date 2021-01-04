class CreatePgSywiretransferTransactions < ActiveRecord::Migration
  def change
    create_table :pg_sywiretransfer_transactions do |t|
      t.date :date_of_transaction
      t.decimal :amount, precision: 10, scale: 2
      t.string :bank_reference_id
      t.string :remitters_bank_details
      t.string :beneficiary_bank_details
      t.string :currency
      t.references :pg_sywiretransfer_merchant

      t.timestamps
    end
  end
end
