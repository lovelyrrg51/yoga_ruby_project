class AddLastVoucherNumberColumnToSyEventCompany < ActiveRecord::Migration[5.1]
  def change
  	unless column_exists? :sy_event_companies, :last_voucher_number
	  	add_column :sy_event_companies, :last_voucher_number, :integer, default: 0
  	end
  end
end
