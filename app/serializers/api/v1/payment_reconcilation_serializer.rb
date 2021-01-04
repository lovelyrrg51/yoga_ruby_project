module Api::V1
  class PaymentReconcilationSerializer < ActiveModel::Serializer
    attributes :id, :reconcilation_ref_number, :status, :file_name, :message, :created_at
  
    def created_at
    	return object.created_at.to_date
    end
  end
end
