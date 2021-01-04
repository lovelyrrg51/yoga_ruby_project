class AddColumnNameOfGuruToSadhakProfile < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :name_of_guru, :string
  end
end
