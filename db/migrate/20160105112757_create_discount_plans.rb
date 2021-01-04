class CreateDiscountPlans < ActiveRecord::Migration
  def change
    create_table :discount_plans do |t|
      t.string :name
      t.integer :discount_type
      t.decimal :discount_amount, precision: 10, scale: 2
      t.integer :user_id

      t.timestamps
    end
  end
end
