class AddForeignKeysToLineItems < ActiveRecord::Migration
  def up
    execute <<-SQL
        ALTER TABLE line_items
        ADD CONSTRAINT fk_line_items_orders
        FOREIGN KEY (order_id)
        REFERENCES orders(id) ON DELETE CASCADE;

        ALTER TABLE line_items
        ADD CONSTRAINT fk_line_items_digital_assets
        FOREIGN KEY (digital_asset_id)
        REFERENCES digital_assets(id);
    SQL
  end
  def down
  	execute <<-SQL
        ALTER TABLE line_items
        DROP CONSTRAINT fk_line_items_orders;
        ALTER TABLE line_items
        DROP CONSTRAINT fk_line_items_digital_assets;
    SQL
  end
end
