module Api::V1
  class StripeConfigSerializer < ActiveModel::Serializer
    attributes :id, :publishable_key, :secret_key, :alias_name, :merchant_id, :country_id, :tax_amount
    
    #embed :ids
    has_one :payment_gateway
    
    def secret_key
      if current_user.present?
        if object.secret_key.present? 
          if current_user.super_admin?
            object.secret_key
          else
            nil
          end
        else
          object.secret_key
        end
      else
        nil
      end
    end
    
    def merchant_id
      if current_user.present?
        if object.merchant_id.present? 
          if current_user.super_admin?
            object.merchant_id
          else
            nil
          end
        else
          object.merchant_id
        end
      else
        nil
      end
    end
  end
end
