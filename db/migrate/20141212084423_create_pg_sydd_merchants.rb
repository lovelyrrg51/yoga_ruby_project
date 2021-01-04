class CreatePgSyddMerchants < ActiveRecord::Migration
  def change
    create_table :pg_sydd_merchants do |t|
      t.string :name
      t.string :domain
      t.string :email
      t.string :mobile
      t.boolean :email_enabled
      t.boolean :sms_enabled
      t.integer :sms_limit
      t.string :public_key
      t.string :private_key

      t.timestamps
    end
  end
end
