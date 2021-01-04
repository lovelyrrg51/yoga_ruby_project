class AddColumnToDiscountPlan < ActiveRecord::Migration
  def change
    add_column :discount_plans, :is_delete, :boolean, default: :false
  end
end
