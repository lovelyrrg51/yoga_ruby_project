module Api::V1
  class PgSyddMerchantSerializer < ActiveModel::Serializer
    attributes :id, :name, :domain, :email, :mobile, :email_enabled, :sms_enabled, :sms_limit, :public_key, :private_key
  end
end
