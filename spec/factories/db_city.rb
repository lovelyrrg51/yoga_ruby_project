FactoryBot.define do
  factory(:db_city) do
    code "MOBI"
    country { DbCountry.first || association(:db_country)}
    dma_id 686
    lat BigDecimal.new("30.6871")
    lng BigDecimal.new("-88.096")
    name "Mobile"
    state { DbState.first || association(:db_state)}
    timezone "ToFactory: RubyParser exception parsing this attribute"
  end
end
