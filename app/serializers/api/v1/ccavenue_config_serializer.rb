module Api::V1
  class CcavenueConfigSerializer < ActiveModel::Serializer
    attributes :id, :alias_name, :working_key, :merchant_id, :access_code, :country_id, :tax_amount
    #embed :ids
    has_one :payment_gateway
    
    
    def working_key
      if current_user.present?
        if object.working_key.present? 
          if current_user.super_admin?
            object.working_key
          else
            nil
          end
        else
          object.working_key
        end
      end
    end
    
    def access_code
      if current_user.present?
        if object.access_code.present? 
          if current_user.super_admin?
            object.access_code
          else
            nil
          end
        else
          object.access_code
        end
      end
    end
    
  end
end
