FactoryBot.define do
  factory(:pandal_detail) do
    arrangement_details "aa"
    chairs_count 3400
    event_id 24
    len BigDecimal.new("1000.0")
    matresses_count 0
    seating_type "chairs"
    width BigDecimal.new("1000.0")
  end
end
