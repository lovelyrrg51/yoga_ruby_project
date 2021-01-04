module Api::V1
  class PgSyPayfastConfigSerializer < ActiveModel::Serializer
    attributes :id, :user_name, :alias_name, :merchant_id, :merchant_key, :country_id, :tax_amount, :payment_gateway_id
  
    def user_name
     return (current_user.present? and current_user.super_admin?) ? object.user_name : nil
    end
  
    def merchant_id
      return (current_user.present? and current_user.super_admin?) ? object.merchant_id : nil
    end
  
    def merchant_key
    	return (current_user.present? and current_user.super_admin?) ? object.merchant_key : nil
    end
  end
end
