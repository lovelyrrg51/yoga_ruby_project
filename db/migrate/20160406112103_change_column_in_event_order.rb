class ChangeColumnInEventOrder < ActiveRecord::Migration
  def change
  	rename_column :event_orders, :payment_gateway_response, :gateway_redirect_url
  end
end
