class AddFeedbackFormToEventType < ActiveRecord::Migration
  def change
    add_column :event_types, :feedback_form, :string
  end
end
