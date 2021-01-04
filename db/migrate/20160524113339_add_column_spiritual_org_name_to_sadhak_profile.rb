class AddColumnSpiritualOrgNameToSadhakProfile < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :spiritual_org_name, :string
  end
end
