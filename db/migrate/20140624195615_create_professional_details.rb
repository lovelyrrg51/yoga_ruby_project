class CreateProfessionalDetails < ActiveRecord::Migration
  def change
    create_table :professional_details do |t|
      t.integer :highest_degree # to be pulled from the enum in SadhakProfile::PHD, SadhakProfile::Masters, SadhakProfile::Bachelors
      t.string :occupation
      t.string :designation
      t.string :industry # TODO:add enum fro naukri.com dropdown as per BRD
      t.string :profession #TODO: populate based on industry
      t.string :area_of_specialization
      t.string :other_profession
      t.string :name_of_organization
      t.integer :years_of_experience
      t.string :personal_interests
      t.string :hobbies
      t.integer :sadhak_profile_id
      t.timestamps
    end
  end
end
