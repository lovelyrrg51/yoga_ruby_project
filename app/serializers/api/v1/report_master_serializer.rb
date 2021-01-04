module Api::V1
  class ReportMasterSerializer < ActiveModel::Serializer
    attributes :id, :report_name
  
    def report_name
      object.report_name.try(:titleize)
    end
  end
end
