class CreateTaxTypes < ActiveRecord::Migration
  def change
    create_table :tax_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
