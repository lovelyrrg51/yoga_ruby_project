class CreateCryptos < ActiveRecord::Migration
  def change
    create_table :cryptos do |t|

      t.timestamps
    end
  end
end
