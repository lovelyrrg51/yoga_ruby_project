class AddForeignKeysToRegistrationModels < ActiveRecord::Migration
  def change
    add_foreign_key :advance_profiles, :sadhak_profiles
    add_foreign_key :aspect_feedbacks, :aspects_of_lives, :column => :aspects_of_life_id
    add_foreign_key :aspects_of_lives, :sadhak_profiles
    add_foreign_key :doctors_profiles, :sadhak_profiles
    add_foreign_key :other_spiritual_associations, :sadhak_profiles
    add_foreign_key :professional_details, :sadhak_profiles
    add_foreign_key :relations, :sadhak_profiles
    add_foreign_key :relations, :users
    add_foreign_key :spiritual_journeys, :sadhak_profiles
    add_foreign_key :spiritual_practices, :sadhak_profiles
    
    add_foreign_key :spiritual_practice_frequent_sadhna_type_associations, :spiritual_practices, name: 'fk_spfsta_spiritual_practice'
    add_foreign_key :spiritual_practice_frequent_sadhna_type_associations, :frequent_sadhna_types, name: 'fk_spfsta_frequent_sadhna_type'
    
    add_foreign_key :spiritual_practice_physical_exercise_type_associations, :spiritual_practices, name: 'fk_sppeta_spiritual_practice'
    add_foreign_key :spiritual_practice_physical_exercise_type_associations, :physical_exercise_types, name: 'fk_sppeta_frequent_physical_exercise_type'
    
    add_foreign_key :spiritual_practice_shivyog_teaching_associations, :spiritual_practices, name: 'fk_spsta_spiritual_practice'
    add_foreign_key :spiritual_practice_shivyog_teaching_associations, :shivyog_teachings, name: 'fk_spsta_frequent_shivyog_teaching'
    
    add_foreign_key :db_cities, :db_countries, :column => :country_id
    add_foreign_key :db_cities, :db_states, :column => :state_id
    add_foreign_key :db_states, :db_countries, :column => :country_id
  end
end
