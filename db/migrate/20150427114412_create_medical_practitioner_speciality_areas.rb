class CreateMedicalPractitionerSpecialityAreas < ActiveRecord::Migration
  def change
    create_table :medical_practitioner_speciality_areas do |t|
      t.string :name

      t.timestamps
    end
  end
end
