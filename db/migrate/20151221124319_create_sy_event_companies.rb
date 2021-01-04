class CreateSyEventCompanies < ActiveRecord::Migration
  def change
    create_table :sy_event_companies do |t|
      t.string :name

      t.timestamps
    end
  end
end
