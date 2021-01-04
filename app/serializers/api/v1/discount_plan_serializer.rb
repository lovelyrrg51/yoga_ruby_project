module Api::V1
  class DiscountPlanSerializer < ActiveModel::Serializer
    attributes :id, :name, :discount_type, :discount_amount, :user_id
    
    #embed :ids
  
    has_many :events                                      
  end
end
