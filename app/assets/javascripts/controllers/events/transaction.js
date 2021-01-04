$(document).on('show.bs.modal', '#event_order_details_modal', function(e) {
  var eventOrderDetails = $(e.relatedTarget).data('event-order-detail'), modalBody = $(this).find('div.modal-body');
  modalBody.html('');
  $.each(eventOrderDetails, function(k, v){
    modalBody.append('<div class="groupBlock row"><label class="col-sm-6 col-xs-6">' + k.humanize() + ':</label><label class="col-sm-6 col-xs-6"><b>' + v + '</b></label></div>')
  });
});

$(document).on('show.bs.modal', '#resend_pre_approval_email_modal', function(e) {
  var target = $(e.relatedTarget), eventOrderRegRefNumber = target.data('event-order-reg-ref-number'), eventOrderResendPreApprovalEmailUrl = target.data('event-order-pre-approval-email-resend-url');

  $(e.currentTarget).find('.modal-body').find('span').html(eventOrderRegRefNumber);
  $(e.currentTarget).find('form').attr('action', eventOrderResendPreApprovalEmailUrl);
});

$(document).on('show.bs.modal', '#event_order_resend_transaction_receipt_modal', function(e) {
  var target = $(e.relatedTarget), eventOrderRegRefNumber = target.data('event-order-reg-ref-number'), eventOrderResendTxnReceiptUrl = target.data('event-order-resend-txn-receipt-url'), eventOrderGuestEmail = target.data('event-order-guest-email');

  $(e.currentTarget).find('.modal-body').find('span:first').html(eventOrderRegRefNumber);
  $(e.currentTarget).find('form').attr('action', eventOrderResendTxnReceiptUrl);
  $('#event_order_recipients').val(eventOrderGuestEmail);
});