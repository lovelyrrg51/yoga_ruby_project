class ChangeProfessionFromProfessionalDetail < ActiveRecord::Migration
  def change
    rename_column :professional_details, :profession, :profession_id
    change_column :professional_details, :profession_id, 'integer USING CAST(profession_id AS integer)'
  end
end
