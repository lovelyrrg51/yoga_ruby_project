$(document).on('show.bs.modal', '#registration_changes_payment_refund_modal', function(e) {
  var target = $(e.relatedTarget), maxRefundableAmount = target.data('registration-change-max-refundable-amount'), registrationChangesRefundUrl = target.data('registration-change-refund-url');

  $(e.currentTarget).find('.modal-body').find('label:first').find('span:first').html(maxRefundableAmount);
  $(e.currentTarget).find('form').attr('action', registrationChangesRefundUrl);
});

$(document).on('show.bs.modal', '#registration_changes_payment_refund_request_cancel_modal', function(e) {
  var target = $(e.relatedTarget), registrationChangeRegRefNumber = target.data('registration-changes-reg-ref-number'), registrationChangePaymentRefundUpdateUrl = target.data('registration-changes-payment-refund-update-url');

  $(e.currentTarget).find('.modal-body').find('label:first').find('span:first').html(registrationChangeRegRefNumber);
  $(e.currentTarget).find('form').attr('action', registrationChangePaymentRefundUpdateUrl);
});


$(document).on('show.bs.modal', '#registration_changes_payment_detail_modal', function(e) {
  var paymentRefundDetail = $(e.relatedTarget).data('payment-refund-detail'), paymentRefundLineItems = $(e.relatedTarget).data('payment-refund-line-items-detail'), modalBody = $(this).find('div.modal-body');
  modalBody.html('');

  modalBody.append('<div class="container" data-role = "perfect-scrollbar" style="position: relative; overflow: auto; height: 300px; width: auto;"></div>')

  var scrollbarDiv = modalBody.find('div.container')
  
  $.each(paymentRefundDetail, function(k, v){
    scrollbarDiv.append('<div class="groupBlock row"><label class="col-sm-6 col-xs-6">' + k.humanize() + ':</label><label class="col-sm-6 col-xs-6"><b>' + v + '</b></label></div>')
  });

  if(paymentRefundLineItems.length > 0) {

    $.each(paymentRefundLineItems, function(i, paymentRefundLineItem){

      scrollbarDiv.append('<br>')

      scrollbarDiv.append('<h4 class="red"> ' + paymentRefundLineItem.syid + '-' + paymentRefundLineItem.full_name + ' Details</h4>')

      $.each(paymentRefundLineItem, function(k, v){
        scrollbarDiv.append('<div class="groupBlock row"><label class="col-sm-6 col-xs-6">' + k.humanize() + ':</label><label class="col-sm-6 col-xs-6"><b>' + v + '</b></label></div>')
      });

    });

  }

});

$(document).on('click', '#payment_refund_default_policy', function(){
  $(this).parents('div.prelative').find('div.overlapping').toggleClass('overlay-active');
  if($('#payment_refund_amount').val()) $('#payment_refund_amount').val('');
  (!$(this).is(':checked')) ? $('#payment_refund_amount').rules("add", { required: true }) : $('#payment_refund_amount').rules("remove")
});