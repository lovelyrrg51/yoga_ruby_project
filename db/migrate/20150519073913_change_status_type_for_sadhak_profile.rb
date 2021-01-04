class ChangeStatusTypeForSadhakProfile < ActiveRecord::Migration
  def change
    change_column :sadhak_profiles, :status, 'integer USING CAST(status AS integer)'
  end
end
