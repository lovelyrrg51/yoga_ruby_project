class ResendTransactionReceiptEmail

  def self.call event_order
    txns = []

    recipients = event_order.user_email.presence || event_order.guest_email
    unless recipients.to_s.is_valid_email?
      raise 'Please input a valid email to receive transaction receipt.'
    end

    TransferredEventOrder.gateways.each do |gateway|
      txn = (Object.const_get gateway[:model]).where(
        event_order_id: event_order.id,
        status: gateway[:success]
      ).collect do |t|
        {
          amount: t[:amount],
          transaction_id: t[gateway[:transaction_id].to_s.to_sym],
          payment_method: gateway[:payment_method]
        }
      end

      txns.concat txn
    end

    raise "Transaction(s) not found associated with reference number #{event_order.reg_ref_number}." if txns.empty?

    total_transactions_amount = txns.collect { |t| t[:amount] }.sum.to_f
    syids = event_order.sadhak_profiles.collect(&:syid).join(',')
    from = GetSenderEmail.call(event_order.event)

    # Fire email only if event order success and payment success
    # or payment method is dd and dd received by RC or Ashram or India Admin
    ApplicationMailer.send_email(
      from: from,
      recipients: recipients,
      template: 'resend_transaction_receipt_email',
      subject: "Duplicate Registration(s) Receipt ##{event_order.reg_ref_number} ##{syids}",
      txns: txns,
      total_transactions_amount: total_transactions_amount,
      event_order: event_order
    ).deliver
  end

end
