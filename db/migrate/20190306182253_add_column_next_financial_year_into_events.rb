class AddColumnNextFinancialYearIntoEvents < ActiveRecord::Migration[5.1]
  def change
  	add_column :events, :next_financial_year, :boolean, default: false
  end
end
