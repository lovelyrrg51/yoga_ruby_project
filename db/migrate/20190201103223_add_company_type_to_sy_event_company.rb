class AddCompanyTypeToSyEventCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :sy_event_companies, :company_type, :integer
  end
end
