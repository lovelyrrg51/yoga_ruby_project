class AddAutomaticRefundColumnToEvent < ActiveRecord::Migration
  def change
    add_column :events, :automatic_refund, :boolean, default: :true
  end
end
