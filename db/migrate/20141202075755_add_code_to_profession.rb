class AddCodeToProfession < ActiveRecord::Migration
  def change
    add_column :professions, :code, :string
  end
end
