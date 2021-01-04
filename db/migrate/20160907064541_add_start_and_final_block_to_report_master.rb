class AddStartAndFinalBlockToReportMaster < ActiveRecord::Migration
  def change
    add_column :report_masters, :start_block, :text
    add_column :report_masters, :final_block, :text
  end
end
