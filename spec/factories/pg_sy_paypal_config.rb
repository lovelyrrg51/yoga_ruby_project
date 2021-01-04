FactoryBot.define do
  factory(:pg_sy_paypal_config) do
    alias_name "Paypal Indonesia Production account"
    country_id 114
    merchant_id nil
    password "QTVFYXFRPGPTRJVR"
    payment_gateway {PaymentGateway.first || association(:payment_gateway)}
    publishable_key ""
    secret_key ""
    signature "AEEAhp4UTLTkKcjmYc5bec2ngcRxAVR1dPWS-DOcUTiOLJDRZ8tZDOZ9"
    tax_amount 0.0
    username "chugani5000_api1.gmail.com"
  end
end
