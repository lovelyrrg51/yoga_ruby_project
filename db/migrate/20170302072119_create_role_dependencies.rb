class CreateRoleDependencies < ActiveRecord::Migration[5.0]
  def change
    create_table :role_dependencies do |t|
      t.references :user_role, index: true
      t.date :start_date
      t.date :end_date
      t.boolean :is_restriction, default: false
      t.integer :whodunnit
      t.datetime :deleted_at
      t.references :role_dependable, polymorphic: true, index: false

      t.timestamps
    end
    add_index :role_dependencies, :deleted_at
    add_index :role_dependencies, [:role_dependable_type, :role_dependable_id], name: 'index_role_dependencies_on_type_and_id'
  end
end
