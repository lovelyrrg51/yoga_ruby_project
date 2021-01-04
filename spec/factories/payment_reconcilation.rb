FactoryBot.define do
  factory(:payment_reconcilation) do
    file_name "orders lookup details1-reconcilation_b0fd60cd6ad"
    message nil
    # method "ccavenue"
    reconcilation_ref_number "reconcilation_b0fd60cd6ad"
    status "completed"
    user_id "122"
  end
end
