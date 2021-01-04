class CreateSyFormFieldAssociations < ActiveRecord::Migration
  def change
    create_table :sy_form_field_associations do |t|
      t.references :sy_form_field, index: true
      t.references :sy_form, index: true
      t.integer :form_field_order

      t.timestamps
    end
  end
end
