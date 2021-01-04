require 'rails_helper'

RSpec.describe TransactionLog, type: :model do

  describe "associations" do

    it { should belong_to(:transaction_loggable) }
    it { should belong_to(:user).optional}
  end

  describe 'enums' do
    it do
      should define_enum_for(:transaction_type).
        with_values([:pay, :refund])
    end

    it do
      should define_enum_for(:gateway_type).
        with_values([:offline, :online])
    end

    it do
      should define_enum_for(:status).
        with_values([:failure, :success, :pending])
    end
  end

  describe 'serializer' do
    it { should serialize(:gateway_request_object) }
    it { should serialize(:gateway_response_object) }
    it { should serialize(:other_detail) }
    it { should serialize(:request_params) }
  end

end
