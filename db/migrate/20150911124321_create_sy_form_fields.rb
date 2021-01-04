class CreateSyFormFields < ActiveRecord::Migration
  def change
    create_table :sy_form_fields do |t|
      t.string :label
      t.text :default_value
      t.string :placeholder
      t.boolean :is_required, default: false
      t.references :sy_form_field_type, index: true

      t.timestamps
    end
  end
end
