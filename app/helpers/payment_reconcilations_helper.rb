module PaymentReconcilationsHelper

  def payment_reconcilation_status_color(payment_reconcilation)

    if payment_reconcilation.initiated?
      "cornblue-color"
    elsif payment_reconcilation.processing?
      "warning-color"
    elsif payment_reconcilation.completed?
      "success-color"
    else
      "primary-color"
    end

  end

  def payment_reconcilation_error_text(payment_reconcilation)

    if payment_reconcilation.initiated?
      "Payment Reconcilation is initiated. Please wait for it\'s completion."
    elsif payment_reconcilation.processing?
      "Payment Reconcilation is under process. Please wait for it\'s completion."
    else
      "Payment Reconcilation process is not completed due to some problem."
    end

  end

end