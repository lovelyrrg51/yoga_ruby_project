module Api::V1
  class DashboardWidgetConfigSerializer < ActiveModel::Serializer
    attributes :id, :is_visible, :widget#, :name
  end
end
