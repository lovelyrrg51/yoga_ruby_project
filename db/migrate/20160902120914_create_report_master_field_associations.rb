class CreateReportMasterFieldAssociations < ActiveRecord::Migration
  def change
    create_table :report_master_field_associations do |t|
      t.references :report_master, index: true
      t.references :report_master_field
      t.text :proc_block
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :report_master_field_associations, :deleted_at
    add_index :report_master_field_associations, :report_master_field_id, name: 'index_report_master_field_ass_on_report_master_field_id'
  end
end
