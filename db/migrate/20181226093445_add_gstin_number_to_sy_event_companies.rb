class AddGstinNumberToSyEventCompanies < ActiveRecord::Migration[5.1]
  def change
  	unless column_exists? :sy_event_companies, :gstin_number
  		add_column :sy_event_companies, :gstin_number, :string
  	end
  end
end
