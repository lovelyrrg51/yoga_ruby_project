class CreateEventSadhakQuestionnaires < ActiveRecord::Migration[5.1]
  def change
    create_table :event_sadhak_questionnaires do |t|
      t.references :event, foreign_key: true
      t.references :sadhak_profile, foreign_key: true
      t.text "data"
      t.string "key"

      t.timestamps
    end
  end
end
