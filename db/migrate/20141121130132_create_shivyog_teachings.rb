class CreateShivyogTeachings < ActiveRecord::Migration
  def change
    create_table :shivyog_teachings do |t|
      t.string :name

      t.timestamps
    end
  end
end
