class AddCommitteeTypeToCommittee < ActiveRecord::Migration
  def change
    add_column :committees, :committee_type, :integer
  end
end
