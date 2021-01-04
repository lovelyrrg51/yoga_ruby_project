class CreateSyFormEventTypeAssociations < ActiveRecord::Migration
  def change
    create_table :sy_form_event_type_associations do |t|
      t.references :event_type, index: true
      t.references :sy_form, index: true

      t.timestamps
    end
  end
end
