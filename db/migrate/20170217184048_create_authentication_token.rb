class CreateAuthenticationToken < ActiveRecord::Migration[5.0]
  def change
    create_table :authentication_tokens do |t|
      t.string :body
      t.references :user, index: true
      t.datetime :last_used_at
      t.string :ip_address
      t.string :user_agent
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :authentication_tokens, :deleted_at
  end
end
