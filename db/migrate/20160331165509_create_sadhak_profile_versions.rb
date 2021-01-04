class CreateSadhakProfileVersions < ActiveRecord::Migration
	TEXT_BYTES = 1_073_741_823
  def change
    create_table   :sadhak_profile_versions do |t|
    	t.string     :item_type, :null => false
      t.integer    :item_id,   :null => false
      t.string     :event,     :null => false
      t.text       :object,    :limit => TEXT_BYTES
      t.string     :ip
      t.float      :latitude
      t.float      :longitude
      t.string     :whodunnit
      t.datetime   :created_at

    end
    add_index :sadhak_profile_versions, [:item_type, :item_id]
  end
end
