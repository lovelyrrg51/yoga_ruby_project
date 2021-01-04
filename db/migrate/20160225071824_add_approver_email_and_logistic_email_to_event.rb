class AddApproverEmailAndLogisticEmailToEvent < ActiveRecord::Migration
  def change
    add_column :events, :approver_email, :string
    add_column :events, :logistic_email, :string
  end
end
