require 'rails_helper'

RSpec.describe SyClubPaymentGatewayAssociation, type: :model do

  it { should belong_to(:payment_gateway) }

end