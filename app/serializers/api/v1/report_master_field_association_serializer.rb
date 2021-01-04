module Api::V1
  class ReportMasterFieldAssociationSerializer < ActiveModel::Serializer
    attributes :id, :report_master_id
  
    #embed :ids
    has_one :report_master_field, include: true
  end
end
