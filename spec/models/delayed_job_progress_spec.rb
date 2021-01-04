require 'rails_helper'

RSpec.describe DelayedJobProgress, type: :model do
  let(:instance) { DelayedJobProgress.new(progress_stage: 'name') }
  # subject { create(:delayed_job_progress) }

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:delayed_job_progressable) }
  end

  describe 'initial state' do
    subject { instance }

    it { is_expected.to have_state(:initiated) }
  end

  it { should serialize(:result) }

  it { should define_enum_for(:status).with_values([:initiated , :processing, :completed, :failed, :error]) }
  
end
