class CreateRegistrationCenters < ActiveRecord::Migration
  def change
    create_table :registration_centers do |t|
      t.string :name

      t.timestamps
    end
  end
end
