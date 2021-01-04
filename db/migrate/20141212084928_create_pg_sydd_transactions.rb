class CreatePgSyddTransactions < ActiveRecord::Migration
  def change
    create_table :pg_sydd_transactions do |t|
      t.string :dd_number
      t.references :pg_sydd_merchant, index: true
      t.date :dd_date
      t.string :bank_name
      t.decimal :amount, precision: 10, scale: 2
      t.text :additional_details

      t.timestamps
    end
  end
end
