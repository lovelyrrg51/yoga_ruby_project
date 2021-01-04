module CcavenueConfigsHelper

  def get_payment_gateway_mode_association(payment_gateway, payment_mode)
    PaymentGatewayModeAssociation.find_by(payment_gateway: payment_gateway, payment_mode: payment_mode)
  end

  def payment_mode_new_edit_url(payment_gateway, payment_mode)

    if payment_mode.payment_gateways.include?(payment_gateway)
      edit_ccavenue_config_payment_gateway_mode_association_path(payment_gateway.send(payment_gateway.payment_gateway_type.try(:relation_name)), get_payment_gateway_mode_association(payment_gateway, payment_mode))
    else
      new_ccavenue_config_payment_gateway_mode_association_path(payment_gateway.send(payment_gateway.payment_gateway_type.try(:relation_name)), payment_mode_id: payment_mode.id)
    end

  end
end


