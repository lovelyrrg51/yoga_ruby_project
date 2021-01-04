class CreateShivyogEventRegistrations < ActiveRecord::Migration
  def change
    create_table :shivyog_event_registrations do |t|
      t.integer :user_id
      t.integer :shivyog_event_id
      t.integer :amount_paid
      t.string :payment_vehicle  #demand draft, payement gateway, etc
      t.string :payment_identification_number # should be number for demand draft, or payment confirmation from payment gateway, etc
      t.string :seating_type
      t.text :special_considerations
      t.timestamps
    end
  end
end
