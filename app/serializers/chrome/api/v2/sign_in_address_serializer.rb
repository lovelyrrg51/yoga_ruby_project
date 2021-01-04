class Chrome::Api::V2::SignInAddressSerializer < ActiveModel::Serializer

    attributes :id, :first_line, :second_line, :district, :postal_code, :country_name, :state_name, :city_name
    
end