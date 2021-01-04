module Api::V1
  class RegistrationCenterSerializer < ActiveModel::Serializer
    attributes :id, :name, :is_cash_allowed, :start_date, :end_date
    
    #embed :ids
    has_many :users
  end
end
