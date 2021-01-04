class AddColumnFieldOptionsToSyFormField < ActiveRecord::Migration
  def change
    add_column :sy_form_fields, :field_options, :string
  end
end
