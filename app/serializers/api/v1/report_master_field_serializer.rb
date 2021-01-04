module Api::V1
  class ReportMasterFieldSerializer < ActiveModel::Serializer
    attributes :id, :field_name
  
    def field_name
      object.try(:field_name).try(:titleize)
    end
  end
end
