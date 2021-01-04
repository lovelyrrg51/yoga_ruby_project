class AddNameOfGuruToOtherSpiritualAssociation < ActiveRecord::Migration
  def change
    add_column :other_spiritual_associations, :name_of_guru, :string
  end
end
