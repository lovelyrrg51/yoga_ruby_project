FactoryBot.define do
  factory(:voucher) do
    voucher_number "1"
    voucher_type [:receipt, :invoice, :refund].sample
  end
end
