class AddAliasNameToPgSyddConfig < ActiveRecord::Migration
  def change
    add_column :pg_sydd_configs, :alias_name, :string
  end
end
