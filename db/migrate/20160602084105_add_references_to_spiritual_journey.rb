class AddReferencesToSpiritualJourney < ActiveRecord::Migration
  def change
    add_reference :spiritual_journeys, :sub_source_type, index: true
    add_column :spiritual_journeys, :alternative_source, :text
  end
end
