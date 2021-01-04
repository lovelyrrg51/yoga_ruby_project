class DashboardWidgetConfig < ApplicationRecord
  validates :widget, presence: :true

  enum widget: {
    forum: 0,
    transfer: 1,
    organiser: 2
  }
end
