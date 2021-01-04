FactoryBot.define do
  factory(:sy_event_company) do
    automatic_invoice false
    gstin_number nil
    is_deleted false
    last_invoice_number 1158
    last_invoice_voucher_number 0
    last_receipt_voucher_number 0
    last_refund_voucher_number 0
    llpin_number ""
    name "Body Mind and Soul"
    service_tax_number ""
    terms_and_conditions "ToFactory: RubyParser exception parsing this attribute"
  end
end
