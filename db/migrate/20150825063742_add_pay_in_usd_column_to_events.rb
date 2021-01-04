class AddPayInUsdColumnToEvents < ActiveRecord::Migration
  def change
    add_column :events, :pay_in_usd, :boolean, default: :false
  end
end
