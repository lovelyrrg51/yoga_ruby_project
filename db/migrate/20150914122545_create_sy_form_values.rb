class CreateSyFormValues < ActiveRecord::Migration
  def change
    create_table :sy_form_values do |t|
      t.string :value
      t.references :sy_form, index: true
      t.references :sy_form_field, index: true
      t.references :sy_form_value_storable, polymorphic: true

      t.timestamps
    end
    add_index :sy_form_values, [:sy_form_value_storable_id, :sy_form_value_storable_type], name: 'index_to_sy_form_value_on_storable_id_and_type'
  end
end
