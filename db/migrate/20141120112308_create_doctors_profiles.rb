class CreateDoctorsProfiles < ActiveRecord::Migration
  def change
    create_table :doctors_profiles do |t|
      t.string :medical_school
      t.string :education_country_id
      t.integer :year_of_graduation
      t.string :area_of_speciality
      t.string :sub_speciality
      t.integer :licence_status
      t.integer :licence_state_id
      t.integer :licence_country_id
      t.string :primary_work_setting
      t.string :practice_place
      t.integer :practice_state_id
      t.integer :practice_country_id
      t.integer :practice_years
      t.boolean :clinical_research
      t.string :hospital_affiliations
      t.string :professional_publications
      t.string :honors_and_awards
      t.integer :sadhak_profile_id
      
      t.timestamps
    end
  end
end
