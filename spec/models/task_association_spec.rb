require 'rails_helper'

RSpec.describe TaskAssociation, type: :model do

  describe "associations" do

    it { should belong_to(:parent_task).class_name('Task').with_foreign_key(:parent_task_id) }
    it { should belong_to(:child_task).class_name('Task').with_foreign_key(:child_task_id)}
  end

end