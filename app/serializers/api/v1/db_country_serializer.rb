module Api::V1
  class DbCountrySerializer < ActiveModel::Serializer
    attributes :id, :name, :telephone_prefix, :currency, :currency_code
  end
end
