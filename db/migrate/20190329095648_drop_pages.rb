class DropPages < ActiveRecord::Migration[5.2]
  def up
    drop_table :pages
  end

  def down
    create_table :pages do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
