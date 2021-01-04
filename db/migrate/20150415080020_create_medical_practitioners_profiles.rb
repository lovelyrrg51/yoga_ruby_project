class CreateMedicalPractitionersProfiles < ActiveRecord::Migration
  def change
    create_table :medical_practitioners_profiles do |t|
      t.string :medical_degree
      t.boolean :practiced_integrative_health_care, default: nil
      t.integer :current_professional_role
      t.string  :other_role
      t.integer :work_enviroment
      t.boolean :interested_in_panel_discussion, default: nil
      t.boolean :interested_in_volunteering, default: nil
      t.string :other_speciality
      t.references :sadhak_profile, index: true

      t.timestamps
    end
  end
end
