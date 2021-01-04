FactoryBot.define do
  factory(:db_state) do
    adm1_code "AS07"
    code "VI"
    country { DbCountry.first || association(:db_country)}
    name "Victoria"
  end
end
