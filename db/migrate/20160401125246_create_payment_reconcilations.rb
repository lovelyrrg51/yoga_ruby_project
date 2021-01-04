class CreatePaymentReconcilations < ActiveRecord::Migration
  def change
    create_table :payment_reconcilations do |t|
      t.string :method
      t.string :reconcilation_ref_number
      t.string :file_name
      t.integer :status
      t.string :user_id
      t.string :message
      t.timestamps
    end
  end
end
