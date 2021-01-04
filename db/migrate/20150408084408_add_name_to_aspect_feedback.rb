class AddNameToAspectFeedback < ActiveRecord::Migration
  def change
    add_column :aspect_feedbacks, :name, :string
  end
end
