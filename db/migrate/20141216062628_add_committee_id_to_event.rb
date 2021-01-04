class AddCommitteeIdToEvent < ActiveRecord::Migration
  def change
    add_reference :events, :committee, index: true
  end
end
