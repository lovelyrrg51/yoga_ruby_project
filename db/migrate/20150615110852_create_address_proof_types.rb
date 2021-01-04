class CreateAddressProofTypes < ActiveRecord::Migration
  def change
    create_table :address_proof_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
