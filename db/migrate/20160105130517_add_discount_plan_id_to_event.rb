class AddDiscountPlanIdToEvent < ActiveRecord::Migration
  def change
    add_reference :events, :discount_plan, index: true
  end
end
