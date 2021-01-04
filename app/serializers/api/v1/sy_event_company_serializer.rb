module Api::V1
  class SyEventCompanySerializer < ActiveModel::Serializer
    # attributes :id, :name, :llpin_number, :service_tax_number, :terms_and_conditions, :automatic_invoice
    attributes :id, :name, :llpin_number, :service_tax_number, :terms_and_conditions, :automatic_invoice, :gstin_number

    
    #embed :ids
    has_one :address, include: true
  end
end
