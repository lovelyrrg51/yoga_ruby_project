require 'rails_helper'

RSpec.describe PaymentReconcilation, type: :model do

  let(:payment_reconcilation) { Class.new }

  describe "associations" do
    # it { should belong_to(:event)} # event_id is not present in table
    it { should have_many(:attachments)}
  end

  it { should accept_nested_attributes_for(:attachments).allow_destroy(true) }

  it do
    should define_enum_for(:status).with_values({initiated: 0, processing: 1, completed: 2, failed: 3 })
  end

  #AASM
  describe 'aasm states' do
    event = FactoryBot.build(:payment_reconcilation)
    it { should have_state(:initiated) }
    it "should transform from initiated to processing" do
      expect(event).to transition_from(:initiated).to(:processing).on_event(:processing)
    end
    it "should transform from processing to completed" do
      expect(event).to transition_from(:processing).to(:completed).on_event(:completed)
    end
    # failed state is not exist
    # it "should transform from processing to failed" do
    #   expect(event).to transition_from(:processing).to(:failed).on_event(:failed)
    # end
  end

  describe "set constants" do
    before { stub_const("#{described_class}", payment_reconcilation) }
    it { expect(described_class::FILE_TYPE).to eq({ original: 0, valid: 1, invalid: 2 }) }
  end
end
