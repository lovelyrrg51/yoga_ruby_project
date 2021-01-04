class AddColumnsFinalBlockOptsTConfigToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :final_block, :text
    add_column :tasks, :opts, :text
    add_column :tasks, :t_config, :text
    add_column :tasks, :start_block, :text
  end
end
