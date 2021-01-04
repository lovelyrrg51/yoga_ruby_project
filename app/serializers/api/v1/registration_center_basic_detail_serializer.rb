module Api::V1
  class RegistrationCenterBasicDetailSerializer < ActiveModel::Serializer
    attributes :id, :name, :is_cash_allowed, :start_date, :end_date
  end
end
