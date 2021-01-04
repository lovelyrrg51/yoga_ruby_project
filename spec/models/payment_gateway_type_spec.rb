require 'rails_helper'

RSpec.describe PaymentGatewayType, type: :model do

  it { should have_many(:payment_gateways)}

end
