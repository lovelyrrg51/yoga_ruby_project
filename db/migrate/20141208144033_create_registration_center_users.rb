class CreateRegistrationCenterUsers < ActiveRecord::Migration
  def change
    create_table :registration_center_users do |t|
      t.references :user
      t.references :registration_center 
      t.foreign_key :users, name: :fk_rcu_user
      t.foreign_key :registration_centers, name: :fk_rcu_registration_center
      
      t.timestamps
    end
  end
end
