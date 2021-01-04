class CreateReportMasterFields < ActiveRecord::Migration
  def change
    create_table :report_master_fields do |t|
      t.string :field_name
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :report_master_fields, :deleted_at
  end
end
