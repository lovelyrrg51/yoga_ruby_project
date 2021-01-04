class CreateDbStates < ActiveRecord::Migration
  def change
    create_table :db_states do |t|
      t.integer :country_id
      t.string :name
      t.string :code
      t.string :adm1_code

      t.timestamps
    end
  end
end
