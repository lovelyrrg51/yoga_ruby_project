class AddEventCancellationPlanIdToEvent < ActiveRecord::Migration
  def change
    add_reference :events, :event_cancellation_plan, index: true
  end
end
