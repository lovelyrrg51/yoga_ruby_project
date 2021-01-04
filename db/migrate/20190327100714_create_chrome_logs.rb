class CreateChromeLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :chrome_logs do |t|
      t.integer :user_id
      t.integer :asset_id
      t.string :status
      t.datetime :date_time
      t.json :data

      t.timestamps
    end
  end
end
