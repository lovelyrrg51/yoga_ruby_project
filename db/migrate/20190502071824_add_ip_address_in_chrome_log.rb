class AddIpAddressInChromeLog < ActiveRecord::Migration[5.1]
  def change
    add_column :chrome_logs, :ip_address, :string
  end
end
