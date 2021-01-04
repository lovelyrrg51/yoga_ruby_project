class CreateVouchers < ActiveRecord::Migration[5.1]
  def change
    unless table_exists?(:vouchers)
      create_table :vouchers do |t|
        t.references :receiptable, polymorphic: true, index: true
        t.integer :voucher_type
        t.string :voucher_number
        t.datetime :deleted_at

        t.timestamps
      end
      add_index :vouchers, :deleted_at
    end
  end
end
