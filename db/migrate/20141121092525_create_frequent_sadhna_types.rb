class CreateFrequentSadhnaTypes < ActiveRecord::Migration
  def change
    create_table :frequent_sadhna_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
