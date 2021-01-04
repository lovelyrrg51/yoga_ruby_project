require 'rails_helper'

RSpec.describe PgSyBraintreeConfig, type: :model do

  it { should belong_to(:payment_gateway).dependent(:destroy)}

  describe "validations" do
    subject {FactoryBot.build(:pg_sy_braintree_config)}
    it { should validate_presence_of(:publishable_key) }
    it { should validate_presence_of(:secret_key) }
    it { should validate_presence_of(:alias_name) }
    it { should validate_presence_of(:payment_gateway) }
    it { should validate_uniqueness_of(:publishable_key) }
    it { should validate_uniqueness_of(:secret_key) }
    it { should validate_uniqueness_of(:alias_name) }
    it { should validate_uniqueness_of(:payment_gateway) }
  end
end
