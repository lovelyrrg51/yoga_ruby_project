module Api::V1
  class SyClubPaymentGatewayAssociationSerializer < ActiveModel::Serializer
    attributes :id, :payment_start_date, :payment_end_date
    #embed :ids
    # has_one :sy_club
    has_one :payment_gateway, include: true
  end
end
