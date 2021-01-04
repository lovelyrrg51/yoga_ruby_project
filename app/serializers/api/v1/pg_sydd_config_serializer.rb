module Api::V1
  class PgSyddConfigSerializer < ActiveModel::Serializer
    attributes :id, :public_key, :private_key, :alias_name, :country_id, :tax_amount
    #embed :ids
    has_one :pg_sydd_merchant
    has_one :payment_gateway
  end
end
