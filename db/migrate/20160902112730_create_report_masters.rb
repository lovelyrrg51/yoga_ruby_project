class CreateReportMasters < ActiveRecord::Migration
  def change
    create_table :report_masters do |t|
      t.string :report_name
      t.text :required_params
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :report_masters, :deleted_at
  end
end
