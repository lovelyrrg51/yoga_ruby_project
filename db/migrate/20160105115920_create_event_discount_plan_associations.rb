class CreateEventDiscountPlanAssociations < ActiveRecord::Migration
  def change
    create_table :event_discount_plan_associations do |t|
      t.references :event, index: true
      t.references :discount_plan, index: true
      t.foreign_key :events, column: :event_id
      t.foreign_key :discount_plans, column: :discount_plan_id
      t.timestamps
    end
  end
end
