require 'rails_helper'
RSpec.describe DashboardWidgetConfig, type: :model do
  it { should validate_presence_of(:widget) }
  it { should define_enum_for(:widget).with_values(forum: 0, transfer: 1, organiser: 2) }
end
