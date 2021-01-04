class AddCountryIdAndTaxAmountToPgSyddConfig < ActiveRecord::Migration
  def change
    add_column :pg_sydd_configs, :country_id, :integer
    add_column :pg_sydd_configs, :tax_amount, :float, precision: 5, scale: 2
  end
end
