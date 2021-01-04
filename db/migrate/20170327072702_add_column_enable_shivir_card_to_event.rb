class AddColumnEnableShivirCardToEvent < ActiveRecord::Migration
  def change
    add_column :events, :shivir_card_enabled, :boolean, default: false
  end
end
