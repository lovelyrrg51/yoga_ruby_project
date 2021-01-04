module Api::V1
  class DelayedJobProgressSerializer < ActiveModel::Serializer
  
    attributes :id, :progress_stage, :result, :last_error, :status, :percentage
  
  end
end
