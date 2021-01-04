class AddForeignKeyToOrders < ActiveRecord::Migration
  def up
    execute <<-SQL
        ALTER TABLE orders
        ADD CONSTRAINT fk_orders_users
        FOREIGN KEY (user_id)
        REFERENCES users(id);

    SQL
  end
  def down
  	execute <<-SQL
        ALTER TABLE orders
        DROP CONSTRAINT fk_orders_users;
    SQL
  end
end
