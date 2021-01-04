FactoryBot.define do
  factory(:pg_sydd_merchant) do
    domain "test"
    email "syit.namahshivay@gmail.com"
    email_enabled nil
    mobile nil
    name "Delhi aashram"
    private_key "test"
    public_key "test"
    sms_enabled true
    sms_limit 120
  end
end
