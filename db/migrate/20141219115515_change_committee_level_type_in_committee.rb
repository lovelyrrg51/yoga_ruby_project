class ChangeCommitteeLevelTypeInCommittee < ActiveRecord::Migration
  def change
     change_column :committees, :committee_level, 'integer USING CAST(committee_level AS integer)', :null => true
  end
end
