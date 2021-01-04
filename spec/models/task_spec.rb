require 'rails_helper'

RSpec.describe Task, type: :model do

  describe "associations" do

    context '#has_many' do
      it { should have_many(:parent_task_associations).class_name('TaskAssociation').with_foreign_key(:child_task_id) }
      it { should have_many(:parent_tasks).through(:parent_task_associations).source(:parent_task)}
      it { should have_many(:child_task_associations).class_name('TaskAssociation').with_foreign_key(:parent_task_id)}
      it { should have_many(:sub_tasks).through(:child_task_associations).source(:child_task)}
    end

    context '#has_one' do
      it { should have_one(:attachment)}
    end

    context '#belong_to' do
      it { should belong_to(:taskable)}  
    end

  end

  describe "validations" do
    subject {Task.new(email: 'test@gmail.com', t_config: {"file_name"=>"Shiv Yog Shambhavi Online... event_registration_report", "prefix"=>"production/reports/event_registration", "template"=>"search_sadhak_result", "sync"=>false})}
    it { should validate_presence_of(:taskable_id) }
    it { should validate_presence_of(:taskable_type) }
    it { should validate_presence_of(:t_config) }
    it { should validate_presence_of(:email)}
  end

  it do
    should define_enum_for(:status).
      with_values([ :initiated, :processing, :completed, :failed ])
  end

  describe '#serialize' do
    it { should serialize(:opts) }
    it { should serialize(:t_config) }
  end

  describe 'aasm states' do
    it { should have_state(:initiated) }
  end

end
