class AddCountryIdAndTaxAmountToStripeConfig < ActiveRecord::Migration
  def change
    add_column :stripe_configs, :country_id, :integer
    add_column :stripe_configs, :tax_amount, :float, precision: 5, scale: 2
  end
end
