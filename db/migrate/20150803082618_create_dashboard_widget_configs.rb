class CreateDashboardWidgetConfigs < ActiveRecord::Migration
  def change
    create_table :dashboard_widget_configs do |t|
      t.boolean :is_visible, default: :true
      t.string :name
      t.integer :widget
      t.timestamps
    end
  end
end
