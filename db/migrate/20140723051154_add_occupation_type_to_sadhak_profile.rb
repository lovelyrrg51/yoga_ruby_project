class AddOccupationTypeToSadhakProfile < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :occupation_type, :string
  end
end
