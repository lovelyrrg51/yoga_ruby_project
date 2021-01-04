class AddColumnSyCompanyIdToEvent < ActiveRecord::Migration
  def change
    add_column :events, :sy_event_company_id, :integer
  end
end
