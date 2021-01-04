module Api::V1
  class PgSyPaypalConfigSerializer < ActiveModel::Serializer
    attributes :id, :username, :password, :signature, :country_id, :tax_amount, :alias_name, :publishable_key, :secret_key, :merchant_id, :payment_gateway_id
    
    
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
    
    # def username
    #   if current_user.present?
    #     if object.username.present? 
    #       if current_user.super_admin?
    #         object.username
    #       else
    #         nil
    #       end
    #     else
    #       object.username
    #     end
    #   else
    #     nil
    #   end
    # end
    
    def password
      if current_user.present?
        if object.password.present? 
          if current_user.super_admin?
            object.password
          else
            nil
          end
        else
          object.password
        end
      else
        nil
      end
    end
    
    def signature
      if current_user.present?
        if object.signature.present? 
          if current_user.super_admin?
            object.signature
          else
            nil
          end
        else
          object.signature
        end
      else
        nil
      end
    end
  end
end
