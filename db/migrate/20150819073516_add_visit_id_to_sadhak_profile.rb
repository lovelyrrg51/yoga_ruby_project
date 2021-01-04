class AddVisitIdToSadhakProfile < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :visit_id, :integer
  end
end
