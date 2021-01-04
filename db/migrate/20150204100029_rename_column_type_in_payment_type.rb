class RenameColumnTypeInPaymentType < ActiveRecord::Migration
  def change
    rename_column :payment_gateway_types, :type, :name
  end
end
