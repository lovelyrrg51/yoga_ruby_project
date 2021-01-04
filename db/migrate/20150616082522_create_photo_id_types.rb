class CreatePhotoIdTypes < ActiveRecord::Migration
  def change
    create_table :photo_id_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
