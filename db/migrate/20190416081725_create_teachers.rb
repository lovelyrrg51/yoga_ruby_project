class CreateTeachers < ActiveRecord::Migration[5.2]
  def change
    create_table :teachers do |t|
      t.string :first_name
      t.string :last_name
      t.string :title
      t.text :bio
      t.string :mobile
      t.string :email
      t.string :skype
      t.string :facebook_profile
      t.string :twitter_profile
      t.string :linkedin_profile
      t.string :pinterest_profile

      t.timestamps
    end
  end
end
