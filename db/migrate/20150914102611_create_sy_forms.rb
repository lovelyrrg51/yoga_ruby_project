class CreateSyForms < ActiveRecord::Migration
  def change
    create_table :sy_forms do |t|
      t.string :name
      t.string :form_type

      t.timestamps
    end
  end
end
