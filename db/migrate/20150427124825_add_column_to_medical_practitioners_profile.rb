class AddColumnToMedicalPractitionersProfile < ActiveRecord::Migration
  def change
    add_column :medical_practitioners_profiles, :medical_practitioner_speciality_area_id, :integer
  end
end
