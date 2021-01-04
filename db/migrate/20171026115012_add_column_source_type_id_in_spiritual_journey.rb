class AddColumnSourceTypeIdInSpiritualJourney < ActiveRecord::Migration
  def change
    add_column :spiritual_journeys, :source_info_type_id, :integer
  end
end
