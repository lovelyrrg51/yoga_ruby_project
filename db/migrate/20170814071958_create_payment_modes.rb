class CreatePaymentModes < ActiveRecord::Migration[5.1]
  def change
    create_table :payment_modes do |t|
      t.string :name
      t.string :shortcode
      t.integer :group_name
      t.datetime :deleted_at
      
      t.timestamps
    end
    add_index :payment_modes, :deleted_at
  end
end
