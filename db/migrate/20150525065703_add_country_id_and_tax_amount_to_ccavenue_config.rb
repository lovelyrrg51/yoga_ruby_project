class AddCountryIdAndTaxAmountToCcavenueConfig < ActiveRecord::Migration
  def change
    add_column :ccavenue_configs, :country_id, :integer
    add_column :ccavenue_configs, :tax_amount, :float, precision: 5, scale: 2
  end
end
