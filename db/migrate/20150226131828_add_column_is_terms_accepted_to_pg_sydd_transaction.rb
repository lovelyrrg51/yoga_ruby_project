class AddColumnIsTermsAcceptedToPgSyddTransaction < ActiveRecord::Migration
  def change
    add_column :pg_sydd_transactions, :is_terms_accepted, :boolean
  end
end
