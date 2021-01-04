class AddMinAgeCriteriaToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :min_age_criteria, :integer
  end
end
